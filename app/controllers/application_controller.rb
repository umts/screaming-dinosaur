# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :set_roster

  authorize :user, through: -> { Current.user }
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do
    render 'application/development_login', status: :unauthorized and next if unauthorized?

    render file: Rails.public_path.join('403.html'), layout: false, status: :forbidden
  end

  protected

  def implicit_authorization_target = self.class.controller_path.to_sym

  def confirm_change(object, message = nil)
    # Rubocop can't tell whether we're redirecting after this or not.
    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    change = object.versions.where(whodunnit: Current.user).last
    flash[:change] = change.try(:id)

    # If we know what change occurred, use it to write the message.
    # If we don't, try and infer from the current controller action.
    # Otherwise, just go with 'updated'.
    event = change.present? ? change.event : (params[:action] || 'update')
    action_taken = event == 'destroy' ? 'deleted' : event.sub(/e?$/, 'ed')
    message ||= "#{object.class.name} has been #{action_taken}."
    flash[:message] = message
    # rubocop:enable Rails/ActionControllerFlashBeforeRender
  end

  private

  def set_current_user
    if Rails.env.local? && session[:user_id].present?
      Current.user = User.active.find_by id: session[:user_id]
    # :nocov:
    elsif shibboleth_spire.present? && shibboleth_primary_account?
      Current.user = User.active.find_by spire: shibboleth_spire
    end
    # :nocov:
  end

  def set_roster
    @roster = Roster.friendly.find(params[:roster_id], allow_nil: true) || Current.user&.rosters&.first || Roster.first
  end

  def shibboleth_spire = request.env['fcIdNumber']

  def shibboleth_primary_account? = request.env['UMAPrimaryAccount'] == request.env['uid']

  def unauthorized? = session[:user_id].nil? && Rails.env.development?
end

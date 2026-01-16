# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authorizable

  before_action :set_roster

  protected

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

  def set_roster
    @roster = Roster.friendly.find(params[:roster_id], allow_nil: true) || Current.user&.rosters&.first || Roster.first
  end
end

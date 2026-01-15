# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  included do
    authorize :user, through: -> { Current.user }

    before_action :set_current_user
    verify_authorized
    rescue_from ActionPolicy::Unauthorized do |exception|
      render 'application/development_login', status: :unauthorized and next if unauthorized?

      raise exception
    end
  end

  protected

  def implicit_authorization_target = self.class.controller_path.to_sym

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

  def shibboleth_spire = request.env['fcIdNumber']

  def shibboleth_primary_account? = request.env['UMAPrimaryAccount'] == request.env['uid']

  def unauthorized? = session[:user_id].nil? && Rails.env.development?
end

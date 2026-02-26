# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    authorize :request, through: :request
    authorize :user, through: -> { Current.user }
    verify_authorized
    rescue_from ActionPolicy::Unauthorized do |exception|
      if Current.user.present?
        raise exception if Current.user.present?
      elsif session[:entra_uid].present?
        redirect_to new_user_path
      else
        render 'application/development_login', layout: 'layouts/application', status: :unauthorized
      end
    end
  end

  protected

  def implicit_authorization_target = self.class.controller_path.to_sym

  private

  def set_current_user
    Current.user = User.find_by(entra_uid: session[:entra_uid])
  end
end

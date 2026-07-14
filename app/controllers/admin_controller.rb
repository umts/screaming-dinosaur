# frozen_string_literal: true

# Parent controller for ActiveAdmin (see config/initializers/active_admin.rb).
# Deliberately not an ApplicationController descendant: ActiveAdmin actions
# don't call authorize!, so Authorizable's verify_authorized would reject them.
class AdminController < ActionController::Base # rubocop:disable Rails/ApplicationController
  protect_from_forgery with: :exception

  protected

  def authenticate_admin_user!
    redirect_to root_path unless current_admin_user&.admin?
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)

    @current_admin_user = User.find_by(entra_uid: session[:entra_uid])
  end
end

# frozen_string_literal: true

# Parent controller for ActiveAdmin (see config/initializers/active_admin.rb).
# Mirrors MaintenanceTasksController: wraps the engine in the app's own
# authorization framework rather than ActiveAdmin's, gating every action on
# ActiveAdminPolicy (which only global admins pass via allow_admins).
# rubocop:disable Rails/ApplicationController
class AdminController < ActionController::Base
  include Authorizable

  # ActiveAdmin::BaseController defines its own #authorize! (action, subject),
  # which shadows ActionPolicy's in the resource controllers. Capture
  # ActionPolicy's here, where it is still in scope, so the gate can reach it.
  alias authorize_admin! authorize!

  before_action :authorize_admin!

  protected

  def implicit_authorization_target = :active_admin

  def current_admin_user = Current.user
end
# rubocop:enable Rails/ApplicationController

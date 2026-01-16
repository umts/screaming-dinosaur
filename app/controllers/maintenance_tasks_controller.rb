# frozen_string_literal: true

# rubocop:disable Rails/ApplicationController
class MaintenanceTasksController < ActionController::Base
  include Authorizable

  before_action :authorize!

  protected

  def implicit_authorization_target = :maintenance_tasks
end
# rubocop:enable Rails/ApplicationController

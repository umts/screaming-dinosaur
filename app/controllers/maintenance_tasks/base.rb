# frozen_string_literal: true

module MaintenanceTasks
  class Base < ActionController::Base
    include Authorizable

    before_action :authorize!

    protected

    def implicit_authorization_target = :maintenance_tasks
  end
end

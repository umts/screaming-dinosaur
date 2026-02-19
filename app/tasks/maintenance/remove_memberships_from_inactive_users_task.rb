# frozen_string_literal: true

module Maintenance
  class RemoveMembershipsFromInactiveUsersTask < MaintenanceTasks::Task
    def collection
      User.inactive.joins(:memberships)
      # Collection to be iterated over
      # Must be Active Record Relation or Array
    end

    def process(user)
      user.memberships.destroy_all
      # The work to be done in a single iteration of the task.
      # This should be idempotent, as the same element may be processed more
      # than once if the task is interrupted and resumed.
    end
  end
end

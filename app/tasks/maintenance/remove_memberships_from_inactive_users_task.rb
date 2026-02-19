# frozen_string_literal: true

module Maintenance
  class RemoveMembershipsFromInactiveUsersTask < MaintenanceTasks::Task
    def collection
      User.inactive.joins(:memberships)
    end

    def process(user)
      user.memberships.destroy_all
    end
  end
end

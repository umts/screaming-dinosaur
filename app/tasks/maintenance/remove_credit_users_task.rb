# frozen_string_literal: true

module Maintenance
  class RemoveCreditUsersTask < MaintenanceTasks::Task
    def collection
      emails = %w[11111111@umass.edu
                  22222222@umass.edu
                  66666666@umass.edu
                  77777777@umass.edu
                  88888888@umass.edu
                  99999999@umass.edu]
      User.where(email: emails)
    end

    def process(element)
      element.assignments.each { |assignment| assignment.update!(user: nil) }
      element.reload.destroy! # Must reload to register the assignments getting re-assigned
    end
  end
end

# frozen_string_literal: true

# :nocov:
module Maintenance
  class ImportEntraUidsTask < MaintenanceTasks::Task
    csv_collection

    def process(row)
      User.find_by!(spire: "#{row['spire_id']}@umass.edu").update!(entra_uid: row['entra_uid'])
    end
  end
end
# :nocov:

class RenameRotationIdToRosterIdInAssignments < ActiveRecord::Migration[5.1]
  def change
    rename_column :assignments, :rotation_id, :roster_id 
  end
end

class RenameRotationIdToRosterIdInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments, :rotation_id, :roster_id 
  end
end

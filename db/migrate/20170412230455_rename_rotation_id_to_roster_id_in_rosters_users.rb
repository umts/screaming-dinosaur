class RenameRotationIdToRosterIdInRostersUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :rosters_users, :rotation_id, :roster_id
  end
end

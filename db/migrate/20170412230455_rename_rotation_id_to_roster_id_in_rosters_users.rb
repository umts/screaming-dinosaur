class RenameRotationIdToRosterIdInRostersUsers < ActiveRecord::Migration
  def change
    rename_column :rosters_users, :rotation_id, :roster_id
  end
end

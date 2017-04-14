class RenameRotationsUsersToRostersUsers < ActiveRecord::Migration
  def change
    rename_table :rotations_users, :rosters_users
  end
end

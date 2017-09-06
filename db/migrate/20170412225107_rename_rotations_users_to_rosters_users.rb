class RenameRotationsUsersToRostersUsers < ActiveRecord::Migration[5.1]
  def change
    rename_table :rotations_users, :rosters_users
  end
end

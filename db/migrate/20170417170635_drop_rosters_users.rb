class DropRostersUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :rosters_users
  end
end

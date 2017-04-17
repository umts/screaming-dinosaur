class DropRostersUsers < ActiveRecord::Migration
  def change
    drop_table :rosters_users
  end
end

class AddSwitchoverTimeToRosters < ActiveRecord::Migration[7.0]
  def change
    add_column :rosters, :switchover, :integer, null: false, default: 17 * 60
  end
end

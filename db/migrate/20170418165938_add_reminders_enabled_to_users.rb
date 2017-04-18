class AddRemindersEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reminders_enabled, :boolean, default: true
  end
end

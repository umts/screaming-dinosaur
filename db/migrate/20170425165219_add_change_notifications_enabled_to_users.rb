class AddChangeNotificationsEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :change_notifications_enabled, :boolean, default: true
  end
end

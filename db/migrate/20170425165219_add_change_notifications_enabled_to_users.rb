class AddChangeNotificationsEnabledToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :change_notifications_enabled, :boolean, default: true
  end
end

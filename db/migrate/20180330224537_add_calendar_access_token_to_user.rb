class AddCalendarAccessTokenToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :calendar_access_token, :string
  end
end

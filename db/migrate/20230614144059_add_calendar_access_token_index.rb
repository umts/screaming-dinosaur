class AddCalendarAccessTokenIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :calendar_access_token, unique: true
  end
end

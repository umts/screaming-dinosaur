class AddIsFallbacktoUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_fallback, :boolean, default: false
  end
end

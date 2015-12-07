class AddIsFallbacktoUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_fallback, :boolean, default: false
  end
end

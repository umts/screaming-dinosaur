class AddFallbackUserIdToRotations < ActiveRecord::Migration
  def change
    add_column :rotations, :fallback_user_id, :integer
    remove_column :users, :is_fallback
  end
end

class AddFallbackUserIdToRotations < ActiveRecord::Migration[5.1]
  def change
    add_column :rotations, :fallback_user_id, :integer
    remove_column :users, :is_fallback
  end
end

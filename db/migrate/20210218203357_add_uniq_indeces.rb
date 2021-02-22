class AddUniqIndeces < ActiveRecord::Migration[6.0]
  def change
    add_index :memberships, [:user_id, :roster_id], unique: true
    add_index :rosters, :name, unique: true
    add_index :users, :spire, unique: true
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end

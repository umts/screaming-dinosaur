class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.integer :roster_id
      t.integer :user_id
      t.boolean :admin, default: false

      t.timestamps  null: false
    end
  end
end

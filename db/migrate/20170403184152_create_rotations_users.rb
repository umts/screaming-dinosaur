class CreateRotationsUsers < ActiveRecord::Migration[5.1]
  def change
    create_join_table :rotations, :users
  end
end

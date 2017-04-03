class CreateRotationsUsers < ActiveRecord::Migration
  def change
    create_join_table :rotations, :users
  end
end

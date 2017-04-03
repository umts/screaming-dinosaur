class CreateRotations < ActiveRecord::Migration
  def change
    create_table :rotations do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

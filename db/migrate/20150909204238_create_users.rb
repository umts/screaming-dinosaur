class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :spire
      t.string :email
      t.string :phone

      t.timestamps null: false
    end
  end
end

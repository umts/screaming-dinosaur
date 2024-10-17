class AddSlugToRosters < ActiveRecord::Migration[7.0]
  def change
    add_column :rosters, :slug, :string
    add_index :rosters, :slug, unique: true
  end
end

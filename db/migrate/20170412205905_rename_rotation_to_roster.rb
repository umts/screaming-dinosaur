class RenameRotationToRoster < ActiveRecord::Migration[5.1]
  def change
    rename_table :rotations, :rosters
  end
end

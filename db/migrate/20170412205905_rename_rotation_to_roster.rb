class RenameRotationToRoster < ActiveRecord::Migration
  def change
    rename_table :rotations, :rosters
  end
end

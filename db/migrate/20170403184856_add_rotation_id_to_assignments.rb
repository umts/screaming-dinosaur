class AddRotationIdToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :rotation_id, :integer
  end
end

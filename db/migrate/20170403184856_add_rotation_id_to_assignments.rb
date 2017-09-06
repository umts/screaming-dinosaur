class AddRotationIdToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :rotation_id, :integer
  end
end

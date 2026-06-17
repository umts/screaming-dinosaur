# frozen_string_literal: true

class AddNameToAssignmentGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :assignment_groups, :name, :string, null: false
  end
end

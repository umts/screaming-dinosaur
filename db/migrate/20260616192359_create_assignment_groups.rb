# frozen_string_literal: true

class CreateAssignmentGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :assignment_groups, &:timestamps

    add_reference :assignments, :assignment_group, null: true, foreign_key: true
  end
end

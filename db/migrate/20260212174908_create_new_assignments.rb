# frozen_string_literal: true

class CreateNewAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :new_assignments do |t|
      t.references :user, foreign_key: true
      t.references :roster, null: false, foreign_key: true
      t.datetime :end_datetime, null: false, precision: 0, index: true
      t.index [:roster_id, :end_datetime], unique: true
      t.timestamps
    end
  end
end

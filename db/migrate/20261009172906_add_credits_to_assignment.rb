# frozen_string_literal: true

class AddCreditsToAssignment < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :credits, :integer, default: 1, null: false
  end
end

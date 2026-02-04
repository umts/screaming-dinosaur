# frozen_string_literal: true

class RemoveActiveFromUsers < ActiveRecord::Migration[8.1]
  def change
   remove_column :users, :active, :boolean, default: true
  end
end

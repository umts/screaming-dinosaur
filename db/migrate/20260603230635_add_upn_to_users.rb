# frozen_string_literal: true

class AddUpnToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :upn, :string
  end
end

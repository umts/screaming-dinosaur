# frozen_string_literal: true

class DropOldAuthColumns < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :spire, unique: true
    remove_column :users, :spire, :string
    remove_column :users, :shibboleth_eppn, :string
  end
end

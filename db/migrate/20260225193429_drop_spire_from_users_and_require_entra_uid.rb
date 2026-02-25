# frozen_string_literal: true

class DropSpireFromUsersAndRequireEntraUid < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :spire, :string
    change_column_null :users, :entra_uid, false
  end
end

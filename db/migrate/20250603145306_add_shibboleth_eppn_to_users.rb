# frozen_string_literal: true

class AddShibbolethEppnToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :shibboleth_eppn, :string
  end
end

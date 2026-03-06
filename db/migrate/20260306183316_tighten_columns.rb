# frozen_string_literal: true

class TightenColumns < ActiveRecord::Migration[8.1]
  def change
    # Assignments ------------------------------------------------------------------------------------------------------

    change_column_null :assignments, :end_date, false

    change_column_null :assignments, :roster_id, false
    reversible do |dir|
      dir.up { change_column :assignments, :roster_id, :bigint }
      dir.down { change_column :assignments, :roster_id, :integer }
    end
    add_index :assignments, :roster_id
    add_foreign_key :assignments, :rosters

    change_column_null :assignments, :start_date, false

    change_column_null :assignments, :user_id, false
    reversible do |dir|
      dir.up { change_column :assignments, :user_id, :bigint }
      dir.down { change_column :assignments, :user_id, :integer }
    end
    add_index :assignments, :user_id
    add_foreign_key :assignments, :users

    # Memberships ------------------------------------------------------------------------------------------------------

    change_column_null :memberships, :admin, false

    change_column_null :memberships, :roster_id, false
    reversible do |dir|
      dir.up { change_column :memberships, :roster_id, :bigint }
      dir.down { change_column :memberships, :roster_id, :integer }
    end
    add_index :memberships, :roster_id
    add_foreign_key :memberships, :rosters

    change_column_null :memberships, :user_id, false
    reversible do |dir|
      dir.up { change_column :memberships, :user_id, :bigint }
      dir.down { change_column :memberships, :user_id, :integer }
    end
    add_index :memberships, :user_id
    add_foreign_key :memberships, :users

    # Rosters ----------------------------------------------------------------------------------------------------------

    reversible do |dir|
      dir.up { change_column :rosters, :fallback_user_id, :bigint }
      dir.down { change_column :rosters, :fallback_user_id, :integer }
    end
    add_index :rosters, :fallback_user_id
    add_foreign_key :rosters, :users, column: :fallback_user_id

    change_column_null :rosters, :name, false
    change_column_null :rosters, :phone, false
    change_column_null :rosters, :slug, false

    # Users ------------------------------------------------------------------------------------------------------------

    change_column_null :users, :active, false
    change_column_null :users, :calendar_access_token, false
    change_column_null :users, :change_notifications_enabled, false
    change_column_null :users, :email, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :phone, false
    change_column_null :users, :reminders_enabled, false

    # Versions ---------------------------------------------------------------------------------------------------------

    reversible do |dir|
      dir.up { change_column :versions, :whodunnit, :bigint }
      dir.down { change_column :versions, :whodunnit, :string }
    end
    add_index :versions, :whodunnit
    add_foreign_key :versions, :users, column: :whodunnit
  end
end

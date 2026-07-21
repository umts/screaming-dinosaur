# frozen_string_literal: true

class SetupContinuousAssignments < ActiveRecord::Migration[8.1]
  class Assignment < ActiveRecord::Base
  end

  class Roster < ActiveRecord::Base
  end

  class Membership < ActiveRecord::Base
  end

  def change
    change_table :assignments do |t|
      t.datetime :end_datetime
      t.index :end_datetime
      t.index %i[roster_id end_datetime], unique: true
      t.change_null :user_id, true
      t.change_null :start_date, true
      t.change_null :end_date, true
    end

    reversible do |dir|
      dir.up do
        # convert dates to datetimes
        Roster.find_each do |roster|
          assignments = Assignment.where(roster_id: roster.id).order(start_date: :asc)
          total_start_date = assignments.first.start_date

          # create "anchor" assignment
          prev = Assignment.create!(roster_id: roster.id,
                                    user_id: nil,
                                    end_date: total_start_date - 1,
                                    end_datetime: total_start_date + roster.switchover.minutes)

          assignments.where.not(id: prev).in_batches do |batch|
            batch.each do |curr|
              # if this assignment was not continuous with the previous, create an empty assignment to fill gap
              if curr.start_date != prev.end_date + 1
                Assignment.create!(roster_id: roster.id,
                                   user_id: nil,
                                   end_datetime: curr.start_date + roster.switchover.minutes)
              end

              # write end datetime and update pointer
              curr.update!(end_datetime: curr.end_date + 1.day + roster.switchover.minutes)
              prev = curr
            end
          end
        end

        # stitch am and eve roster together
        am = Roster.find_by!(name: 'Transit Ops AM')
        eve = Roster.find_by!(name: 'Transit Ops EVE')
        ops = Roster.create!(name: 'Transit Operations',
                             phone: am.phone,
                             created_at: [am.created_at, eve.created_at].min,
                             slug: 'transit-operations')
        Membership.where(roster_id: [am.id, eve.id]).each do |old|
          Membership.find_or_create_by!(roster_id: ops.id, user_id: old.user_id).tap do |new|
            new.update!(admin: true) if old.admin?
          end
          old.destroy!
        end
        Assignment.where(roster_id: [am.id, eve.id]).each do |assignment|
          assignment.update!(roster_id: ops.id)
        end
        am.destroy!
        eve.destroy!
      end

      dir.down do
        Roster.find_each do |roster|
          assignments = Assignment.where(roster_id: roster.id).order(end_datetime: :asc)
          next if assignments.empty?

          prev = assignments.first

          assignments.where.not(id: prev).in_batches do |batch|
            batch.each do |curr|
              # write dates and update pointer
              curr.update!(start_date: prev.end_datetime, end_date: curr.end_datetime - 1.day)
              prev = curr
            end
          end

          assignments.where(user_id: nil).find_each(&:destroy!)
        end
      end
    end

    change_column_null :assignments, :end_datetime, false
    remove_column :assignments, :start_date, :date
    remove_column :assignments, :end_date, :date

    remove_column :rosters, :switchover, :integer, default: 1020, null: false

    create_table :assignment_groups do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :assignments, :assignment_group, null: true, foreign_key: true
  end
end

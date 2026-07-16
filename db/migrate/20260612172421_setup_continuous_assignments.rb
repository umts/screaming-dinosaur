# frozen_string_literal: true

class SetupContinuousAssignments < ActiveRecord::Migration[8.1]
  class Roster < ActiveRecord::Base
  end

  class Assignment < ActiveRecord::Base
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
        Roster.find_each do |roster|
          assignments = Assignment.where(roster_id: roster.id).order(start_date: :asc)
          total_start_date = assignments.first.start_date
          next if assignments.empty?

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

        am = Roster.find_by(name: 'Transit Ops AM')
        eve = Roster.find_by(name: 'Transit Ops EVE')
        next if am.nil? || eve.nil?

        ops = Roster.create!(
        name: 'Transit Operations',
        phone: am.phone,
        created_at: [am.created_at, eve.created_at].min,
        slug: 'transit-operations'
        )

        move_memberships(from: [am, eve], to: ops)
        move_assignments(from: [am, eve], to: ops)

        am.delete
        eve.delete
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

        ops = Roster.find_by(name: 'Transit Operations')
        next if ops.nil?

        am = Roster.create!(name: 'Transit Ops AM', phone: ops.phone, created_at: ops.created_at, slug: 'transit-ops-am')
        eve = Roster.create!(name: 'Transit Ops EVE', phone: ops.phone, created_at: ops.created_at, slug: 'transit-ops-eve')

        Membership.where(roster_id: ops.id).each do |membership|
        Membership.create!(roster_id: am.id, user_id: membership.user_id, admin: membership.admin)
        Membership.create!(roster_id: eve.id, user_id: membership.user_id, admin: membership.admin)
       end

        Assignment.where(roster_id: ops.id).delete_all
        Membership.where(roster_id: ops.id).delete_all
        ops.delete
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

  private

  def move_memberships(from:, to:)
    from.each do |roster|
      Membership.where(roster_id: roster.id).to_a.each do |membership|
        existing = Membership.find_by(
          roster_id: to.id,
          user_id: membership.user_id
        )

        if existing
          existing.update!(admin: existing.admin || membership.admin)
          membership.destroy!
        else
          membership.update!(roster_id: to.id)
        end
      end
    end
  end

  def move_assignments(from:, to:)
    from.each do |roster|
      Assignment.where(roster_id: roster.id).to_a.each do |assignment|
        assignment.update!(roster_id: to.id)
      end
    end
  end
end

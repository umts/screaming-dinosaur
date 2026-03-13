# frozen_string_literal: true

class SetupContinuousAssignment < ActiveRecord::Migration[8.1]
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
      end

      dir.down do
        Roster.find_each do |roster|
          assignments = Assignment.where(roster_id: roster.id).order(end_datetime: :asc)

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
  end
end

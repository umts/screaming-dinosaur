# frozen_string_literal: true

class SendAssignmentRemindersJob < ApplicationJob
  def perform
    assignments_in_next_week.group_by(&:user).each do |user, assignments|
      AssignmentsMailer.upcoming_reminder(user, assignments).deliver_now
    end
  end

  private

  def assignments_in_next_week # rubocop:disable Metrics/AbcSize
    start_time = (Date.current.beginning_of_week(:monday) + 1.week).in_time_zone.beginning_of_day
    end_time = start_time + 1.week
    start_datetime = Assignment.arel_table[:start_datetime]
    Assignment.with_start_datetimes.where(start_datetime.gteq(start_time))
              .where(start_datetime.lt(end_time))
              .where.not(user_id: nil)
              .includes(:roster, :user)
  end
end

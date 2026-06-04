# frozen_string_literal: true

class CheckRostersUncoveredDatesJob < ApplicationJob
  def perform
    Roster.find_each do |roster|
      open_dates = roster.uncovered_datetimes_between(Time.current, 2.weeks.from_now)
      next if open_dates.empty? || roster.admins.empty?

      RosterMailer.with(roster:, open_dates:).open_dates_alert.deliver_now
    end
  end
end

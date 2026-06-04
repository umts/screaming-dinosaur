# frozen_string_literal: true

class CheckRostersUncoveredDatesJob < ApplicationJob
  def perform
    Roster.find_each do |roster|
      open_periods = roster.uncovered_periods_between(Time.zone.now, 2.weeks.from_now)
      next if open_periods.empty? || roster.admins.empty?

      RosterMailer.with(roster:, open_periods:).open_dates_alert.deliver_now
    end
  end
end

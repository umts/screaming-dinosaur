# frozen_string_literal: true

class RosterMailerPreview < ActionMailer::Preview
  def open_dates_alert
    roster = Roster.first
    open_dates = roster.uncovered_dates_between(Time.zone.now, 2.weeks.from_now)
    RosterMailer.with(roster:, open_dates:).open_dates_alert
  end
end

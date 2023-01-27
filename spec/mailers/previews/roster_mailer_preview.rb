# frozen_string_literal: true

class RosterMailerPreview < ActionMailer::Preview
  def open_dates_alert
    RosterMailer.with(roster: Roster.first).open_dates_alert
  end
end

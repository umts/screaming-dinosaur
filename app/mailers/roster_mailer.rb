# frozen_string_literal: true

class RosterMailer < ApplicationMailer
  before_action { @roster = params[:roster] }

  def open_dates_alert
    @open_dates = @roster.check_for_open_dates_between(Time.zone.now, 2.weeks.from_now)
    mail to: @roster.admins.pluck(:email), subject: "Upcoming dates are uncovered for #{@roster.name} On-Call"
    mail.perform_deliveries = false if @open_dates.empty?
  end
end

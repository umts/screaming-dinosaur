# frozen_string_literal: true

class RosterMailer < ApplicationMailer
  before_action { @roster = params[:roster] }

  def open_dates_alert
    @open_dates = params[:open_dates]
    mail to: @roster.admins.pluck(:email), subject: "Upcoming dates are uncovered for #{@roster.name} On-Call"
  end

  def fallback_number_changed
    mail to: @roster.admins.pluck(:email), subject: "Fallback number changed for #{@roster.name} On-Call"
  end
end

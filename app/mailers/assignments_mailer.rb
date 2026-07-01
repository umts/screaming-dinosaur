# frozen_string_literal: true

class AssignmentsMailer < ApplicationMailer
  def changed_assignment(roster, start_datetime, end_datetime, recipient, changer)
    set_defaults(roster, start_datetime, end_datetime, recipient, changer)
    mail to: @recipient.email,
         subject: "Change to upcoming on-call (#{@roster.name})"
  end

  def deleted_assignment(roster, start_datetime, end_datetime, recipient, changer)
    set_defaults(roster, start_datetime, end_datetime, recipient, changer)
    mail to: @recipient.email,
         subject: "Cancellation of upcoming on-call (#{@roster.name})"
  end

  def new_assignment(roster, start_datetime, end_datetime, recipient, changer)
    set_defaults(roster, start_datetime, end_datetime, recipient, changer)
    mail to: @recipient.email,
         subject: "New upcoming on-call (#{@roster.name})"
  end

  def upcoming_reminder(recipient, assignments)
    @recipient = recipient
    @assignments = assignments
    mail to: @recipient.email
  end

  private

  def set_defaults(roster, start_datetime, end_datetime, recipient = nil, changer = nil)
    # rubocop:disable Style/ParallelAssignment
    @roster, @recipient, @changer = roster, recipient, changer
    # rubocop:enable Style/ParallelAssignment
    @start_datetime = start_datetime.strftime('%A, %B %e at %-l:%M %P')
    @end_datetime = end_datetime.strftime('%A, %B %e at %-l:%M %P')
  end
end

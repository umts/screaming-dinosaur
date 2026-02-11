# frozen_string_literal: true

class AssignmentsMailer < ApplicationMailer
  def changed_assignment(roster, start_date, end_date, recipient, changer)
    set_defaults(roster, start_date, end_date, recipient, changer)
    mail to: @recipient.email,
         subject: "Change to upcoming on-call (#{@roster.name})"
  end

  def deleted_assignment(roster, start_date, end_date, recipient, changer)
    set_defaults(roster, start_date, end_date, recipient, changer)
    mail to: @recipient.email,
         subject: "Cancellation of upcoming on-call (#{@roster.name})"
  end

  def new_assignment(roster, start_date, end_date, recipient, changer)
    set_defaults(roster, start_date, end_date, recipient, changer)
    mail to: @recipient.email,
         subject: "New upcoming on-call (#{@roster.name})"
  end

  def upcoming_reminder(roster, start_date, end_date, recipient)
    set_defaults(roster, start_date, end_date, recipient)
    mail to: @recipient.email,
         subject: "Reminder: Upcoming on-call (#{@roster.name})"
  end

  def overlap_warning(roster, start_date, end_date, recipient, overlapping_assignments)
    set_defaults(roster, start_date, end_date, recipient)
    @overlapping_assignments = overlapping_assignments
    mail to: @recipient.email,
         subject: "Warning: Overlapping Assignments (#{@roster.name})"
  end

  private

  def set_defaults(roster, start_date, end_date, recipient = nil, changer = nil)
    # rubocop:disable Style/ParallelAssignment
    @roster, @recipient, @changer = roster, recipient, changer
    # rubocop:enable Style/ParallelAssignment
    @start_date = start_date.strftime '%A, %B %e at %-l:%M %P'
    @end_date = end_date.strftime '%A, %B %e at %-l:%M %P'
  end
end

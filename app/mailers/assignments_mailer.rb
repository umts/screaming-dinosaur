# frozen_string_literal: true
class AssignmentsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def changed_assignment(assignment, recipient, changer)
    set_defaults(assignment, recipient, changer)
    mail to: @recipient.email,
         subject: "Change to upcoming on-call (#{@roster.name})"
  end

  def deleted_assignment(assignment, recipient, changer)
    set_defaults(assignment, recipient, changer)
    mail to: @recipient.email,
         subject: "Cancellation of upcoming on-call (#{@roster.name})"
  end

  def new_assignment(assignment, recipient, changer)
    set_defaults(assignment, recipient, changer)
    mail to: @recipient.email,
         subject: "New upcoming on-call (#{@roster.name})"
  end

  def upcoming_reminder(assignment)
    set_defaults(assignment)
    mail to: @user.email,
         subject: "Reminder: Upcoming on-call (#{@roster.name})"
  end

  private

  def set_defaults(assignment, recipient = nil, changer = nil)
    @assignment, @recipient, @changer = assignment, recipient, changer
    @user = @assignment.user
    @roster = @assignment.roster
    @start_date = @assignment.effective_start_datetime
                             .strftime '%A, %B %e at %-l:%M %P'
    @end_date = @assignment.effective_end_datetime
                           .strftime '%A, %B %e at %-l:%M %P'
  end
end

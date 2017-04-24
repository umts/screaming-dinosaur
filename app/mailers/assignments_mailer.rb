# frozen_string_literal: true
class AssignmentsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def changed_assignment(assignment, changer)
    set_defaults(*args)
    mail to: @user.email,
         subject: "Change to upcoming on-call (#{@roster.name})"
  end

  def deleted_assignment(assignment, changer)
    set_defaults(*args)
    mail to: @user.email,
         subject: "Cancellation of upcoming on-call (#{@roster.name})"
  end

  def new_assignment(assignment, changer)
    set_defaults(*args)
    mail to: @user.email,
         subject: "New upcoming on-call (#{@roster.name})"
  end

  def upcoming_reminder(assignment)
    set_defaults(*args)
    mail to: @user.email,
         subject: "Reminder: Upcoming on-call (#{@roster.name})"
  end

  private

  def set_defaults(assignment, changer = nil)
    @user = @assignment.user
    @changer = changer
    @roster = @assignment.roster
    @start_date = @assignment.effective_start_datetime
                            .strftime '%A, %B %e at %-l:%M %P'
    @end_date = @assignment.effective_end_datetime
                          .strftime '%A, %B %e at %-l:%M %P'

  end
end

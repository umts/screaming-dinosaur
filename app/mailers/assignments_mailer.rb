# frozen_string_literal: true
class AssignmentsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def upcoming_reminder(assignment, user)
    @roster = assignment.roster
    @user = user
    @start_date = assignment.start_date.strftime '%A, %B %e'
    # Assignments effectively end at the switchover hour on the following day.
    @end_date = assignment.end_date.succ.strftime '%A, %B %e'
    @time = HOURS.fetch CONFIG[:switchover_hour]
    mail to: user.email,
         subject: "Upcoming on-call (#{@roster.name})"
  end
end

# frozen_string_literal: true
class AssignmentsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def upcoming_reminder(assignment, user)
    @roster = assignment.roster
    @user = user
    @start_date = assignment.effective_start_datetime
                            .strftime '%A, %B %e at %-l:%M %P'
    @end_date = assignment.effective_end_datetime
                          .strftime '%A, %B %e at %-l:%M %P'
    mail to: user.email,
         subject: "Upcoming on-call (#{@roster.name})"
  end
end

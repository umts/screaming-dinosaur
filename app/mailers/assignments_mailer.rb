class AssignmentsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def upcoming_reminder(assignment, user)
    @roster = assignment.roster
    @user = user
    @start_date = assignment.start_date.strftime '%A, %B %e'
    @end_date = assignment.end_date.strftime '%A, %B %e'
    @time = HOURS.fetch CONFIG[:switchover_hour]
    mail to: user.email,
         subject: "Upcoming on-call (#{@roster.name})"
  end
end

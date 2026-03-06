# frozen_string_literal: true

env 'PATH', '/opt/ruby/bin:/usr/sbin:/usr/bin:/sbin:/bin'

every :day, at: '9:00am' do
  runner 'SendAssignmentRemindersJob.perform_now'
end

every :day, at: '4:00am' do
  runner 'CheckRostersUncoveredDatesJob.perform_now'
end

# frozen_string_literal: true

env 'PATH', '/opt/ruby/bin:/usr/sbin:/usr/bin:/sbin:/bin'

every :day, at: '9:00am' do
  runner 'Assignment.send_reminders!'
end

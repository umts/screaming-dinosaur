# frozen_string_literal: true

RSpec.describe 'ICS views' do
  shared_examples 'ics assignments feed' do
    subject(:lines) { page.html.split("\r\n") }

    let(:roster) { create :roster }
    let(:assignments) do
      Array.new(2) do |n|
        create :assignment,
               roster: roster,
               start_date: n.weeks.from_now,
               end_date: (n.weeks + 6.days).from_now
      end
    end
    let(:users) { assignments.map(&:user) }

    before { submit }

    2.times do |n|
      it "contains a summary for assignment ##{n + 1}" do
        expect(lines).to include(summary(users[n]))
      end

      it "contains a description for assignment ##{n + 1}" do
        expect(lines).to include(description(users[n], roster))
      end

      it "contains the dates for assignment ##{n + 1}" do
        expect(lines).to include(*assignment_dates(assignments[n]))
      end
    end

    def summary(user)
      "SUMMARY:#{user.last_name}"
    end

    def description(user, roster)
      "DESCRIPTION:#{user.first_name} #{user.last_name} " \
      "is on call for #{roster.name}."
    end

    def assignment_dates(assignment)
      ["DTSTART;VALUE=DATE:#{assignment.start_date.to_fs(:number)}",
       "DTEND;VALUE=DATE:#{(assignment.end_date + 1.day).to_fs(:number)}"]
    end
  end

  describe 'viewing the ics formatted index' do
    let :submit do
      when_current_user_is users[0]
      visit roster_assignments_path(roster, format: 'ics')
    end

    include_examples 'ics assignments feed'
  end

  describe 'viewing the ics feed' do
    let :submit do
      name = roster.name.parameterize
      visit "feed/#{name}/#{users[0].calendar_access_token}.ics"
    end

    include_examples 'ics assignments feed'
  end
end

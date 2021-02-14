# frozen_string_literal: true

RSpec.describe 'ICS views' do
  shared_examples 'ics assignments feed' do
    let(:roster) { create :roster }
    let(:user) { roster_user(roster) }
    let(:lines) { page.html.split("\r\n") }

    it 'contains correctly formatted data' do
      new_user = roster_user(roster)
      assignment1 = create :assignment, roster: roster, user: user
      assignment2 = create :assignment, roster: roster, user: new_user,
                                        start_date: 1.week.ago,
                                        end_date: 2.days.ago
      submit

      expect(lines).to include(summary(user))
      expect(lines).to include(description(user, roster))
      expect(lines).to include(*assignment_dates(assignment1))
      expect(lines).to include(summary(new_user))
      expect(lines).to include(description(new_user, roster))
      expect(lines).to include(*assignment_dates(assignment2))
    end

    def summary(user)
      "SUMMARY:#{user.last_name}"
    end

    def description(user, roster)
      "DESCRIPTION:#{user.first_name} #{user.last_name} " \
      "is on call for #{roster.name}."
    end

    def assignment_dates(assignment)
      ["DTSTART;VALUE=DATE:#{assignment.start_date.to_s(:number)}",
       "DTEND;VALUE=DATE:#{(assignment.end_date + 1.day).to_s(:number)}"]
    end
  end

  describe 'viewing the ics formatted index' do
    let :submit do
      set_current_user(user)
      visit roster_assignments_path(roster, format: 'ics')
    end

    include_examples 'ics assignments feed'
  end

  describe 'viewing the ics feed' do
    let :submit do
      name = roster.name.parameterize
      visit "feed/#{name}/#{user.calendar_access_token}.ics"
    end

    include_examples 'ics assignments feed'
  end
end

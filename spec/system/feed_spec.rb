# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ICS views' do
  shared_examples 'an ics assignments feed' do
    subject(:lines) { page.html.split("\r\n") }

    let(:roster) { create :roster, created_at: 2.weeks.ago }
    let!(:assignments) do
      Array.new(2) do |n|
        create :assignment, roster:,
                            user: create(:user, rosters: [roster]),
                            end_datetime: (n + 1).weeks.from_now
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

      it "contains the datetimes for assignment ##{n + 1}" do
        expect(lines).to include(*assignment_datetimes(assignments[n]))
      end
    end

    def summary(user)
      "SUMMARY:#{user.last_name}"
    end

    def description(user, roster)
      "DESCRIPTION:#{user.first_name} #{user.last_name} " \
        "is on call for #{roster.name}."
    end

    def assignment_datetimes(assignment)
      ["DTSTART:#{assignment.start_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}",
       "DTEND:#{assignment.end_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}"]
    end
  end

  shared_examples 'an ics feed that excludes unassigned rows' do
    subject(:body) { page.html }

    let(:roster) { create :roster, created_at: 2.weeks.ago }
    let(:user) { create :user, rosters: [roster] }
    let!(:unassigned) do
      create :assignment, roster:, user: nil, end_datetime: 1.week.from_now
    end
    let!(:assigned) do
      create :assignment, roster:, user:, end_datetime: 2.weeks.from_now
    end

    before { submit }

    it 'includes the assigned event' do
      expect(body).to include("#{assigned.id}@screaming-dinosaur")
    end

    it 'does not include the unassigned event' do
      expect(body).not_to include("#{unassigned.id}@screaming-dinosaur")
    end
  end

  describe 'viewing the ics feed' do
    let :submit do
      name = roster.name.parameterize
      visit "/feed/#{name}/#{users[0].calendar_access_token}.ics"
    end

    it_behaves_like 'an ics assignments feed'
  end

  describe 'viewing the ics feed when the roster has unassigned rows' do
    let :submit do
      name = roster.name.parameterize
      visit "/feed/#{name}/#{user.calendar_access_token}.ics"
    end

    it_behaves_like 'an ics feed that excludes unassigned rows'
  end
end

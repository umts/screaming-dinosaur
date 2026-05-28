# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ICS views' do
  shared_examples 'an ics assignments feed' do
    subject(:lines) { page.html.split("\r\n") }

    let(:now) { Time.current }
    let(:roster) { create :roster }
    let(:assignments) do
      Array.new(2) do |n|
        create :assignment, roster:, user: (create :user),
                            end_datetime: now + (n + 1).weeks
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
      ["DTSTART:#{assignment.start_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}",
       "DTEND:#{assignment.end_datetime.utc.strftime('%Y%m%dT%H%M%SZ')}"]
    end
  end

  describe 'viewing the ics feed' do
    let :submit do
      create :membership, roster: roster, user: users[0]
      visit feed_path(roster_id: roster, token: users[0].calendar_access_token)
    end

    it_behaves_like 'an ics assignments feed'
  end
end

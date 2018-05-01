# frozen_string_literal: true

require 'spec_helper'

describe 'viewing the index' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  describe 'viewing the calendar' do
    before :each do
      Timecop.freeze Date.new(2017, 8, 14)
      set_current_user(user)
    end

    after :each do
      Timecop.return
    end

    it 'highlights today' do
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td.cal-cell.current-day', text: '14')
    end
    context 'assignment belongs to user' do
      it 'appears highlighted for your assignment' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: user, roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('td .cal-event.assignment-user', count: 7)
      end
    end

    context 'assignment does not belong to user' do
      it 'appears highlighted differently for other assignments' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: roster_user(roster), roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('td .cal-event.assignment', count: 7)
      end
    end

    context 'start of assignment' do
      it 'has a left radius' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: user, roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('td .cal-event.assignment-start', count: 1)
      end
    end

    context 'end of assignment' do
      it 'has a right radius and a different width than the cell' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: user, roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('td .cal-event.assignment-end.width',
                                      count: 1)
      end
    end

    context 'start and end of assignment on same day' do
      it 'has a radius around the day and a smaller width than the cell' do
        create :assignment, start_date: Date.today, end_date: Date.today,
                            user: user, roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('td .cal-event.assignment-only.width',
                                      count: 1)
      end
    end
  end

  context 'active page highlighted in the nav bar' do
    it 'applies active class to current tab in nav-bar' do
      set_current_user(user)
      visit roster_assignments_url(roster)
      expect(page).to have_selector('nav li.active', count: 1)
    end
  end

  describe 'viewing the ics formatted index' do
    let :submit do
      visit "feed/#{roster.name}/#{user.calendar_access_token}.ics"
    end
    it 'ics file contains correctly formatted data' do
      new_user = create :user, rosters: [roster]
      assignment1 = create :assignment, roster: roster, user: user
      assignment2 = create :assignment, roster: roster, user: new_user,
             start_date: 1.week.ago, end_date: 2.days.ago
      submit
      expect(page.html).to include("SUMMARY:#{user.
          last_name}\nDESCRIPTION:#{user.first_name} #{user.
          last_name} is on call for #{roster.name}.",
                           "DTSTART;VALUE=DATE:#{assignment1.
                               start_date.
                               to_s(:number)}\nDTEND;VALUE=DATE:#{(assignment1.
                               end_date + 1.day).to_s(:number)}")
      expect(page.html).to include("SUMMARY:#{new_user.
          last_name}\nDESCRIPTION:#{new_user.first_name} #{new_user.
          last_name} is on call for #{roster.name}.",
                                   "DTSTART;VALUE=DATE:#{assignment2.
                                       start_date.
                                       to_s(:number)}\nDTEND;VALUE=DATE:#{(assignment2.
                                       end_date + 1.day).to_s(:number)}")
    end
  end
end

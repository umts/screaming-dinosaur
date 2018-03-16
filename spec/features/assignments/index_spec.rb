# frozen_string_literal: true

require 'spec_helper'

describe 'viewing the calendar' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
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

  context 'active page highlighted in the nav bar' do
    it 'applies active class to current tab in nav-bar' do
      visit roster_assignments_url(roster)
      expect(page).to have_selector('nav li.active', count: 1)
    end
  end
end

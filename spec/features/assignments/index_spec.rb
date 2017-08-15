# frozen_string_literal: true

require 'rails_helper'

describe 'viewing the calendar' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  before :each do
    Timecop.freeze Date.new(2017, 8, 14)
    set_current_user(user)
  end

  it 'highlights today' do
    visit roster_assignments_url(roster)
    expect(page).to have_selector('td.cal-cell.current-day', text: '14')
  end
  context 'assignment belongs to user' do
    it 'appears highlighted yellow for your assignment' do
      create :assignment, start_date: 2.days.ago, end_date: 2.days.since,
                          user: user, roster: roster
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td .cal-event.assignment-user', count: 5)
    end
  end

  context 'assignment does not belong to user' do
    it 'appears highlighted blue for other assignments' do
      create :assignment, start_date: 2.days.ago, end_date: 2.days.since,
                          user: roster_user(roster), roster: roster
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td .cal-event.assignment', count: 5)
    end
  end

  context 'start of assignment' do
    it 'has a left radius and a smaller width' do
      create :assignment, start_date: 2.days.ago, end_date: 2.days.since,
                          user: user, roster: roster
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td .cal-event.assignment-start', count: 1)
    end
  end

  context 'end of assignment' do
    it 'has a right radius' do
      create :assignment, start_date: 2.days.ago, end_date: 2.days.since,
             user: user, roster: roster
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td .cal-event.assignment-end.width',
                                    count: 1)
    end
  end

  context 'start and end of assignment' do
    it 'has a radius around the day and a smaller width' do
      create :assignment, start_date: Date.today, end_date: Date.today,
                          user: user, roster: roster
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td .cal-event.assignment-only.width',
                                    count: 1)
    end
  end
end
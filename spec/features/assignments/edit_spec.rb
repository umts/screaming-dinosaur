# frozen_string_literal: true

require 'rails_helper'

describe 'edit an assignment' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  let(:assignment) { create :assignment, user: user, roster: roster, start_date: @start_date }
  before :each do
    Timecop.freeze Date.new(2018, 1, 10)
    set_current_user(user)
  end
  after :each do
    Timecop.return
  end

  context 'returns the user to the appropriate index page' do
    before :each do
      @date_today = Date.new(2017, 4, 4)
      @start_date = Date.new(2017, 3, 31)
      @month_date = @date_today
                        .beginning_of_month
    end
    it 'redirects to the correct URL' do
      visit roster_assignments_url(roster, date: @date_today)
      visit edit_roster_assignment_url(roster, assignment)
      click_button 'Save'
      expect(current_url)
        .to eq roster_assignments_url(roster,
                                      date: @month_date)
    end
    it 'displays the correct month' do
      visit roster_assignments_url(roster, date: @date_today)
      visit edit_roster_assignment_url(roster, assignment)
      click_button 'Save'
      expect(page).to have_selector '.title', text: (@month_date.strftime '%-B %G')
    end
  end
end

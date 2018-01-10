# frozen_string_literal: true

require 'rails_helper'

describe 'edit an assignment' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  let(:assignment) { create :assignment, user: user, roster: roster }
  before :each do
    Timecop.freeze Date.new(2018, 1, 10)
    set_current_user(user)
  end
  after :each do
    Timecop.return
  end

  it 'returns the user to the appropriate index page' do
    date_today = Date.new(2017, 4, 4)
    start_date = Date.new(2017, 3, 31)
    assignment.start_date = start_date
    visit roster_assignments_url(roster, date: date_today)
    visit edit_roster_assignment_url(roster, assignment)
    click_button 'Save'
    expect(current_url)
        .to eq roster_assignments_url(roster,
                                                     date: date_today
                                                               .beginning_of_month)
  end
end
# frozen_string_literal: true

RSpec.describe 'edit an assignment' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }

  around :each do |example|
    Timecop.freeze Date.new(2018, 1, 10) do
      set_current_user(user)
      example.run
    end
  end

  context 'returns the user to the appropriate index page' do
    let(:date_today) { Date.new(2017, 4, 4) }
    let(:start_date) { Date.new(2017, 3, 31) }
    let(:month_date) { date_today.beginning_of_month }
    it 'redirects to the correct URL' do
      visit roster_assignments_url(roster, date: date_today)
      visit new_roster_assignment_url(roster, date: start_date)
      click_button 'Create'
      expect(current_url)
        .to eq roster_assignments_url(roster,
                                      date: month_date)
    end
    it 'displays the correct month' do
      visit roster_assignments_url(roster, date: date_today)
      visit new_roster_assignment_url(roster, date: start_date)
      click_button 'Create'
      expect(page).to have_selector '.title',
                                    text: month_date.strftime('%-B %G')
    end
  end
end

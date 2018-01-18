# frozen_string_literal: true

require 'rails_helper'

describe 'edit an assignment' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  let(:assignment) do
    create :assignment,
           user: user,
           roster: roster,
           start_date: start_date,
           end_date: end_date
  end
  let(:date_today) { Date.new(2017, 4, 4) }
  let(:start_date) { Date.new(2017, 3, 31) }
  let(:end_date) { Date.new(2017, 4, 6) }
  before :each do
    Timecop.freeze Date.new(2017, 3, 31)
    set_current_user(user)
  end
  after :each do
    Timecop.return
  end

  context 'returns the user to the appropriate index page' do
    let(:month_date) do
      date_today.beginning_of_month
    end
    it 'redirects to the correct URL' do
      assignment.start_date = start_date
      visit roster_assignments_url(roster, date: date_today)
      visit edit_roster_assignment_url(roster, assignment)
      click_button 'Save'
      expect(current_url)
        .to eq roster_assignments_url(roster,
                                      date: month_date)
    end
    it 'displays the correct month' do
      visit roster_assignments_url(roster, date: date_today)
      visit edit_roster_assignment_url(roster, assignment)
      click_button 'Save'
      expect(page).to have_selector '.title',
                                    text: month_date.strftime('%-B %G')
    end
  end
  context 'Viewing the page' do
    it 'displays the correct owner' do
      last_name = assignment.user.last_name
      visit edit_roster_assignment_url(roster, assignment)
      expect(page).to have_selector :select, text: last_name
    end
    it 'displays the start date' do
      visit edit_roster_assignment_url(roster, assignment)
      expect(find_field('assignment_start_date').value)
        .to eq start_date.strftime('%Y-%m-%d')
    end
    it 'displays the end date' do
      visit edit_roster_assignment_url(roster, assignment)
      expect(find_field('assignment_end_date').value)
        .to eq end_date.strftime('%Y-%m-%d')
    end
  end
  context 'changing the assignment' do
    let(:last_name) { user.last_name }
    it 'updates the assignment' do
      # Visit the index on the correct month to ensure the form
      # submit returns us to the correct month
      visit roster_assignments_url(roster, date: date_today)
      visit edit_roster_assignment_url(roster, assignment)
      fill_in('assignment[end_date]', with: date_today)
      click_button 'Save'
      # Since the assignment is now 5 days long
      expect(page).to have_selector 'a',
                                    text: last_name, count: 5
    end
    it 'destroys the assignment' do
      visit edit_roster_assignment_url(roster, assignment)
      click_button 'Delete assignment'
      expect(page).not_to have_selector 'a',
                                        text: last_name
    end
  end
  context 'only correct users can edit assignment' do
    before :each do
      @new_user = create :user, rosters: [roster]
      @last_name = @new_user.last_name
    end
    it 'stops users from changing assignments they do not own' do
      visit edit_roster_assignment_url(roster, assignment)
      select(@last_name, from: :assignment_user_id)
      click_button 'Save'
      within('div.alert.alert-danger') do
        expect(page).to have_selector 'li', text: 'You may only edit'
      end
    end
    it 'allows admin users to edit all assignments' do
      membership = user.membership_in(roster)
      membership.admin = true
      membership.save
      visit roster_assignments_url(roster, date: date_today)
      visit edit_roster_assignment_url(roster, assignment)
      select(@last_name, from: :assignment_user_id)
      click_button 'Save'
      # Since the assignment is 7 days long
      expect(page).to have_selector 'a',
                                    text: @last_name, count: 7
    end
  end
end

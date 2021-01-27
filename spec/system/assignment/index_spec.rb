# frozen_string_literal: true

RSpec.describe 'viewing the index' do
  let(:roster) { create :roster }
  let(:user) { roster_user(roster) }

  context 'interacting with the ICS feed URL', js: true do
    before :each do
      set_current_user(user)
      visit root_url
    end
    it 'displays copy url info' do
      find('.glyphicon-info-sign').click.hover
      expect(page).to have_selector '.tooltip',
                                    text: 'Use this address to subscribe'
    end
    it 'displays click to copy tooltip' do
      find('.copy-text-btn').hover
      expect(page).to have_selector '.tooltip', text: 'Click to copy link'
    end
    it 'copys link on button press' do
      find('.copy-text-btn').click.hover
      expect(page).to have_selector '.tooltip', text: 'Copied successfully!'
    end
  end

  describe 'interacting with the calendar', js: true do
    before(:each) do
      set_current_user(user)
    end

    it 'highlights today' do
      visit roster_assignments_url(roster)
      expect(page).to have_selector('td.fc-day-today', text: Time.zone.today.day)
    end

    context 'assignment belongs to user' do
      it 'appears highlighted for your assignment' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: user, roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('.assignment-event-owned')
      end
    end

    context 'assignment does not belong to user' do
      it 'appears highlighted differently for other assignments' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: roster_user(roster), roster: roster
        visit roster_assignments_url(roster)
        expect(page).to have_selector('.assignment-event:not(.assignment-event-owned)')
      end
    end

    context 'clicking on an empty day' do
      it 'sends you to create a new assignment' do
        visit roster_assignments_url(roster)
        execute_script 'calendar.gotoDate("2021-02-01")'
        find('td.fc-day', text: '14').click
        expect(page).to have_current_path(
          new_roster_assignment_path(roster_id: roster.id, date: '2021-02-14')
        )
      end
    end
  end
end

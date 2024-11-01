# frozen_string_literal: true

RSpec.describe 'viewing the index' do
  let(:roster) { create :roster }
  let(:user) { roster_user(roster) }

  context 'when interacting with the ICS feed URL', :js do
    before do
      set_current_user(user)
      visit root_path
    end

    it 'displays copy url info' do
      find("[aria-label='Calendar feed information']").click
      expect(page).to have_css '.tooltip',
                               text: 'Use this address to subscribe'
    end

    it 'displays click to copy tooltip' do
      find('.copy-tooltip').hover
      expect(page).to have_css '.tooltip', text: 'Copy to clipboard'
    end

    it 'copys link on button press' do
      find('.copy-tooltip').click.hover
      expect(page).to have_css '.tooltip', text: 'Copied successfully!'
    end
  end

  describe 'when interacting with the calendar', :js do
    def bg_variable(var)
      /background-color: *var\(--#{var}\)/
    end

    before do
      set_current_user(user)
    end

    it 'highlights today' do
      visit roster_assignments_path(roster)
      today = Time.zone.today.day
      expect(page).to have_css('td.fc-day-today', text: today)
    end

    context 'when the assignment belongs to the user' do
      it 'appears highlighted for your assignment' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: user, roster: roster
        visit roster_assignments_path(roster)
        expect(find_all('.fc-event').pluck('style'))
          .to all(match(bg_variable('bs-info')))
      end
    end

    context 'when the assignment does not belong to the user' do
      it 'appears highlighted differently for other assignments' do
        create :assignment, start_date: 3.days.ago, end_date: 3.days.since,
                            user: roster_user(roster), roster: roster
        visit roster_assignments_path(roster)
        expect(find_all('.fc-event').pluck('style'))
          .to all(match(bg_variable('bs-secondary')))
      end
    end

    context 'when clicking on an empty day' do
      let(:date) { Time.zone.today.change(day: 14) }
      let(:new_path) do
        new_roster_assignment_path roster, date: date.to_fs(:db)
      end

      it 'sends you to create a new assignment' do
        visit roster_assignments_path(roster)

        find('td.fc-day', text: '14').click
        expect(page).to have_current_path(new_path)
      end
    end

    context 'when switching months' do
      before do
        visit roster_assignments_path(roster)
        3.times { click_on 'Next month' }

        # Go anywhere else
        visit edit_roster_user_path(roster, user)
      end

      it 'stores the last viewed month' do
        visit roster_assignments_path(roster)

        three_months_from_now = 3.months.from_now.strftime('%B %Y')
        expect(page).to have_text(three_months_from_now)
      end
    end
  end
end

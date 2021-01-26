# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:membership) { create :membership, admin: true }
  let(:admin) { create :user, memberships: [membership] }

  context 'copying ics url', js: true do
    before :each do
      set_current_user(admin)
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
end

describe 'viewing the index' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }
  describe 'viewing the calendar' do
    around :each do |example|
      Timecop.freeze Date.new(2017, 8, 14) do
        set_current_user(user)
        example.run
      end
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
        expect(page).to have_selector('td .cal-event.assignment-start',
                                      count: 1)
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

  shared_examples 'ics assignments feed' do
    let(:lines) { page.html.split("\r\n") }

    it 'contains correctly formatted data' do
      new_user = create :user, rosters: [roster]
      assignment1 = create :assignment, roster: roster, user: user
      assignment2 = create :assignment, roster: roster, user: new_user,
                                        start_date: 1.week.ago,
                                        end_date: 2.days.ago
      submit

      expect(lines).to include(summary(user))
      expect(lines).to include(description(user, roster))
      expect(lines).to include(*assignment_dates(assignment1))
      expect(lines).to include(summary(new_user))
      expect(lines).to include(description(new_user, roster))
      expect(lines).to include(*assignment_dates(assignment2))
    end

    def summary(user)
      "SUMMARY:#{user.last_name}"
    end

    def description(user, roster)
      "DESCRIPTION:#{user.first_name} #{user.last_name} " \
      "is on call for #{roster.name}."
    end

    def assignment_dates(assignment)
      ["DTSTART;VALUE=DATE:#{assignment.start_date.to_s(:number)}",
       "DTEND;VALUE=DATE:#{(assignment.end_date + 1.day).to_s(:number)}"]
    end
  end

  describe 'viewing the ics formatted index' do
    let :submit do
      set_current_user(user)
      visit roster_assignments_path(roster, format: 'ics')
    end

    include_examples 'ics assignments feed'
  end

  describe 'viewing the ics feed' do
    let :submit do
      name = roster.name.parameterize
      visit "feed/#{name}/#{user.calendar_access_token}.ics"
    end

    include_examples 'ics assignments feed'
  end
end

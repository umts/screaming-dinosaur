# frozen_string_literal: true

RSpec.describe 'user index' do
  describe 'deactivating a user', :js do
    before do
      roster = create :roster
      create :user, first_name: 'Bobo', last_name: 'Test', memberships: [build(:membership, roster:)]

      current_user = create :user, memberships: [build(:membership, roster:, admin: true)]
      login_as current_user

      visit root_path
      click_on 'Manage Users'
      within('tr', text: 'Bobo Test') { accept_alert { click_button 'Deactivate' } }
    end

    it 'no longer lists the user on the roster index' do
      expect(page).to have_no_text('Bobo Test')
    end

    it 'informs you of success' do
      expect(page).to have_text('User has been updated.')
    end
  end

  context 'when viewing the index' do
    let(:roster) { create :roster }
    let(:admin_membership) { create :membership, roster:, admin: true }
    let(:admin) { admin_membership.user }
    let(:current_user) { admin }

    before do
      visit root_path
      click_link 'Manage Users'
    end

    it 'directs you to the appropriate page' do
      expect(page).to have_current_path(roster_memberships_path(admin_membership.roster))
    end

    it 'has a title' do
      expect(page).to have_css 'h1', text: 'Users'
    end

    context 'when viewing active users' do
      it 'shows inactive users button' do
        expect(page).to have_link 'Inactive'
      end

      it 'shows deactivate user button on users' do
        within 'tr', text: admin.first_name do
          expect(page).to have_button 'Deactivate'
        end
      end
    end

    context 'when viewing inactive users' do
      let(:inactive_user) { create :user, active: false }

      before do
        create :membership, roster: roster, user: inactive_user
        click_link 'Inactive'
      end

      it 'shows active users button' do
        expect(page).to have_link 'Active'
      end

      it 'shows activate user button on users' do
        within 'tr', text: inactive_user.first_name do
          expect(page).to have_button 'Activate'
        end
      end

      it 'activates a user' do
        click_button 'Activate'
        expect(page).to have_css 'td', text: inactive_user.first_name
      end

      it 'informs you of success' do
        click_button 'Activate'
        expect(page).to have_css 'div', text: 'User has been updated.'
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe 'user index' do
  let(:roster) { create :roster }
  let(:admin_membership) { create :membership, roster:, admin: true }
  let(:admin) { admin_membership.user }

  context 'when deactivating a user', :js do
    let(:alert) { accept_alert { click_button 'Deactivate' } }

    before do
      when_current_user_is admin
      visit root_path
      click_link 'Manage Users'
    end

    it 'warns current user before deactivation with a pop up' do
      expect(alert).to eq('Deactivating user will delete all upcoming assignments.')
    end

    it 'deactivates a user' do
      alert
      expect(page).to have_no_css 'td', text: admin.first_name
    end

    it 'informs you of success' do
      alert
      expect(page).to have_css 'div', text: 'User has been updated.'
    end
  end

  context 'when viewing the index' do
    before do
      set_current_user(admin)
      visit root_path
      click_link 'Manage Users'
    end

    it 'directs you to the appropriate page' do
      expect(page).to have_current_path(roster_users_path(admin_membership.roster))
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

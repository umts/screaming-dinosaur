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
      expect(page).to have_text('Successfully updated user')
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
      expect(page).to have_current_path(roster_users_path(admin_membership.roster))
    end

    it 'has a title' do
      expect(page).to have_css 'h1', text: 'Users'
    end
  end
end

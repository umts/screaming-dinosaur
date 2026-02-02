# frozen_string_literal: true

RSpec.describe 'user index' do
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

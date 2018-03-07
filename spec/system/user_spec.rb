# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:membership) { create :membership, admin: true}
  let!(:admin) { create :user, first_name: 'tester', memberships: [membership] }

  context 'viewing the index' do
    it 'directs you to the appropriate page' do
      set_current_user(admin)
      visit root_url
      click_link 'Manage users'
      expect(current_url).to end_with roster_users_path(membership.roster)
      # users_path isn't a path defined by our config/routes.rb
      # expect(page.current_url).to end_with users_path
      expect(page).to have_selector 'h1', text: 'Users'
    end
  end
end

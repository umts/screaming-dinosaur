# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'user pages' do
  let(:admin_membership) { create :membership, admin: true }
  let(:admin) { admin_membership.user }
  context 'deactivating a user', js: true do
    before :each do
      when_current_user_is admin
      visit root_path
      click_link 'Manage users'
      click_button 'Deactivate'
      @dialog = page.driver.browser.switch_to.alert
    end
    it 'warns current user before deactivation with a pop up' do
      expect(@dialog.text).to eq 'Deactivating user will delete all upcoming' \
        ' assignments.'
    end
    it 'deactivates a user' do
      @dialog.accept
      expect(page).to have_selector 'div', text: 'User has been updated.'
      expect(page).not_to have_selector 'td', text: admin.first_name
    end
  end
end

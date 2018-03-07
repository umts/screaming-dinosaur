# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:membership) { create :membership, admin: true}
  let(:admin) { create :user, memberships: [membership] }

  context 'viewing the index' do
    it 'directs you to the appropriate page' do
      set_current_user(admin)
      visit root_url
      click_button 'Manage Users'
      expect(page.current_url).to end_with users_path
      expect(page).to have_selector 'h1', text: 'Users'
    end
  end
end

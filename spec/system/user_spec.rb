# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:user) { create :user }
  let(:admin) { create :user, admin: true }

  context 'viewing the index' do
    it 'directs you to the appropriate page' do
      # when_current_user_is(:admin)
      visit root_url
      click_button 'Manage Users'
      expect(page.current_url).to end_with users_path
      expect(page).to have_selector 'h1', text: 'Users'
    end
  end
end

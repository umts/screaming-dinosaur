# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:roster) { create :roster }
  let(:admin_membership) { create :membership, roster: roster, admin: true }
  let(:admin) { admin_membership.user }
  context 'viewing the index' do
    before :each do
      set_current_user(admin)
      visit root_path
      click_link 'Manage users'
    end
    it 'directs you to the appropriate page' do
      expect(current_url).to end_with roster_users_path(admin_membership.roster)
      expect(page).to have_selector 'h1', text: 'Users'
    end
    context 'active users' do
      it 'shows inactive users button' do
        expect(page).to have_link 'Inactive users'
      end
      it 'shows deactivate user button on users' do
        expect(page).to have_selector 'td', text: admin.first_name
        expect(page).to have_button 'Deactivate'
      end
      # deactivate user test under system test directory
    end
    context 'inactive users' do
      before :each do
        @inactive_user = create :user, active: false
        @membership = create :membership, roster: roster, user: @inactive_user
        click_link 'Inactive users'
      end
      it 'shows active users button' do
        expect(page).to have_link 'Active users'
      end
      it 'shows activate user button on users' do
        expect(page).to have_selector 'td', text: @inactive_user.first_name
        expect(page).to have_button 'Activate'
      end
      it 'activates a user' do
        click_button 'Activate'
        expect(page).to have_selector 'div', text: 'User has been updated.'
        expect(page).to have_selector 'td', text: @inactive_user.first_name
      end
    end
  end
end
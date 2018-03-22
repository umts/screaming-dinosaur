# frozen_string_literal: true

require 'spec_helper'

describe 'user pages' do
  let(:roster) { create :roster }
  let(:admin_membership) { create :membership, roster: roster, admin: true }
  let(:admin) { create :user, memberships: [admin_membership] }
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
    context 'displays active users' do
      it 'shows inactive users button' do
        expect(page).to have_link 'Inactive users'
      end
      it 'shows deactivate user button on users' do
        expect(page).to have_selector 'td', text: admin.first_name
        expect(page).to have_button 'Deactivate'
      end
    end
    context 'displays inactive users' do
      before :each do
        @membership = create :membership, roster: roster
        @inactive_user = create :user, memberships: [@membership],
                                active: false
        click_link 'Inactive users'
      end
      it 'shows active users button' do
        expect(page).to have_link 'Active users'
      end
      it 'shows activate user button on users' do
        expect(page).to have_selector 'td', text: @inactive_user.first_name
        expect(page).to have_button 'Activate'
      end
    end
  end
end
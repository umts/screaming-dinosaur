# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Memberships' do
  describe 'membership pagination' do
    let(:roster) { create :roster }
    let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

    before do
      30.times { create(:membership, roster:) }
    end

    it 'shows pagination controls' do
      visit roster_memberships_path(roster)

      expect(page).to have_css("nav[aria-label='Pages']")
    end

    it 'navigates to the second page' do
      visit roster_memberships_path(roster)
      first(:link, '2').click

      expect(page).to have_current_path("#{roster_memberships_path(roster)}?page=2")
    end
  end
end

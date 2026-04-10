# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Undo', :versioning do
  describe 'updating a roster' do
    let(:roster) { create :roster }
    let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

    context 'when making changes' do
      it 'shows an undo button' do
        visit edit_roster_path(roster)
        fill_in 'Name', with: 'New Roster Name'
        click_on 'Save'

        expect(page).to have_button 'Undo'
      end
    end

    context 'when making no changes' do
      it 'does not show an undo button' do
        visit edit_roster_path(roster)
        click_on 'Save'

        expect(page).to have_no_button 'Undo'
      end
    end
  end
end

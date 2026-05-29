# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Undo', :versioning do
  describe 'saving a record' do
    include_context 'when logged in as an admin of the roster'

    let(:roster) { create :roster }

    before { visit edit_roster_path(roster) }

    context 'when making changes' do
      before do
        fill_in 'Name', with: 'New Name'
        click_on 'Save'
      end

      it 'offers an undo button after saving' do
        expect(page).to have_button('Undo')
      end
    end

    context 'when not making changes' do
      before { click_on 'Save' }

      it 'does not show an undo button' do
        expect(page).to have_no_button('Undo')
      end
    end
  end
end

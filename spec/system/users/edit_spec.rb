# frozen_string_literal: true

RSpec.describe 'user editing' do
  context 'when the current user is an admin' do
    let(:roster) { create :roster }
    let(:user) { roster_admin roster }

    let(:current_user) { user }

    context 'when they are the only admin' do
      it 'is prohibitted to make yourself a non-admin' do
        visit edit_roster_user_path(roster, user)
        expect(page).to have_field("Admin in #{roster.name}",
                                   type: 'checkbox', disabled: true)
      end
    end

    context 'when there is another admin' do
      before { roster_admin roster }

      it 'is allowed to make yourself a non-admin' do
        visit edit_roster_user_path(roster, user)
        expect(page).to have_field("Admin in #{roster.name}",
                                   type: 'checkbox', disabled: false)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe 'user editing' do
  context 'as an admin' do
    let(:roster) { create :roster }
    let(:user) { roster_admin roster }
    before { when_current_user_is user }


    context 'as the only admin' do
      it 'is prohibitted to make yourself a non-admin' do
        visit edit_roster_user_path(roster, user)
        expect(page).to have_field("Admin in #{roster.name}",
                                   type: 'checkbox', disabled: true)
      end
    end

    context 'with another admin' do
      before { roster_admin roster }

      it 'is allowed to make yourself a non-admin' do
        visit edit_roster_user_path(roster, user)
        expect(page).to have_field("Admin in #{roster.name}",
                                   type: 'checkbox', disabled: false)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe 'user editing' do
  context 'when the current user is an admin' do
    let(:roster) { create :roster }
    let(:user) { roster_admin roster }

    before { when_current_user_is user }

    context 'when they are the only admin' do
      it 'is prohibitted to make yourself a non-admin' do
        visit edit_user_path(user)
        expect(page).to have_field(id: /user_memberships_attributes_\d+_admin/, type: 'checkbox', disabled: true)
      end
    end

    context 'when there is another admin' do
      before { roster_admin roster }

      it 'is allowed to make yourself a non-admin' do
        visit edit_user_path(user)
        expect(page).to have_field(id: /user_memberships_attributes_\d+_admin/, type: 'checkbox', disabled: false)

        # expect(page).to have_field(name: "user[memberships_attributes][#{roster.id}][admin]",
        #                            type: 'checkbox', disabled: false)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  describe 'registering as a new user' do
    before do
      Rails.application.env_config['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'entra_id',
        uid: 'new-user',
        info: { email: 'registrant@umass.edu', first_name: 'New', last_name: 'User' },
        extra: { raw_info: { 'upn' => 'registrant-af@umass.edu' } }
      )
      visit '/auth/entra_id/callback'
      visit new_user_path
    end

    after { Rails.application.env_config.delete('omniauth.auth') }

    it 'displays the UPN as a disabled field' do
      expect(page).to have_field('Microsoft account', with: 'registrant-af@umass.edu', disabled: true)
    end
  end

  describe 'editing a user' do
    let(:user) { create :user }

    before { visit edit_user_path(user) }

    context 'when logged in as a system admin' do
      let(:current_user) { create :user, admin: true }

      it 'displays the entra_uid as an editable field' do
        expect(page).to have_field('user_entra_uid', with: user.entra_uid, disabled: false)
      end
    end

    context 'when logged in as a system admin editing themselves' do
      let(:current_user) { create :user, admin: true }
      let(:user) { current_user }

      it 'displays the entra_uid as a disabled field' do
        expect(page).to have_field('user_entra_uid', with: user.entra_uid, disabled: true)
      end
    end

    context 'when logged in as the user to edit' do
      let(:current_user) { user }

      it 'does not display the entra_uid field' do
        expect(page).to have_no_field('user_entra_uid')
      end
    end
  end
end

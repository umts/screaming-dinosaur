# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'POST /logout' do
    subject(:submit) { post '/logout' }

    before { allow(Rails.application).to receive(:credentials).and_return(entra_id: { tenant_id: 'tenant' }) }

    it 'redirects you to the entra logout url' do
      submit
      expect(response).to redirect_to(
        "https://login.microsoftonline.com/tenant/oauth2/v2.0/logout?post_logout_redirect_uri=#{CGI.escape(root_url)}"
      )
    end
  end

  describe 'GET /auth/entra_id/callback' do
    subject(:call) { get '/auth/entra_id/callback' }

    let(:auth_uid) { 'entra-uid-1' }

    before do
      Rails.application.env_config['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'entra_id',
        uid: auth_uid,
        info: { email: 'someone@umass.edu', first_name: 'Some', last_name: 'One' },
        extra: { raw_info: { 'upn' => 'someone-upn@umass.edu' } }
      )
    end

    after { Rails.application.env_config.delete('omniauth.auth') }

    context 'when a user with the entra_uid exists' do
      let!(:user) { create(:user, entra_uid: auth_uid) }

      it 'updates the user entra_upn from the auth hash' do
        expect { call }.to change { user.reload.entra_upn }.to('someone-upn@umass.edu')
      end
    end

    context 'when no user matches the entra_uid' do
      it 'does not raise' do
        expect { call }.not_to raise_error
      end
    end
  end

  describe 'visiting an authenticated page as an unregistered user' do
    before { get '/auth/developer/callback', params: { uid: 'unregistered-uid' } }

    it 'redirects to the registration page' do
      get '/rosters'
      expect(response).to redirect_to(new_user_path)
    end
  end
end

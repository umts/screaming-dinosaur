# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'GET /auth/:provider/callback' do
    context 'when the provider gives a UPN in raw_info' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'entra_id',
          uid: 'entra-uid-1',
          info: { email: 'a@x.com', first_name: 'A', last_name: 'X' },
          extra: { raw_info: { 'upn' => 'a@x.com' } }
        )
      end

      before { Rails.application.env_config['omniauth.auth'] = auth_hash }
      after { Rails.application.env_config.delete('omniauth.auth') }

      it 'records the UPN in the session' do
        get '/auth/entra_id/callback'
        expect(session[:upn]).to eq 'a@x.com'
      end

      context 'when the matching user is missing a UPN' do
        let!(:user) { create :user, entra_uid: 'entra-uid-1', upn: nil }

        it 'updates the stored UPN' do
          expect { get '/auth/entra_id/callback' }.to change { user.reload.upn }.from(nil).to('a@x.com')
        end
      end

      context "when the matching user's stored UPN differs" do
        let!(:user) { create :user, entra_uid: 'entra-uid-1', upn: 'old@x.com' }

        it 'updates the stored UPN' do
          expect { get '/auth/entra_id/callback' }.to change { user.reload.upn }.to('a@x.com')
        end
      end

      context "when the matching user's stored UPN matches" do
        let!(:user) { create :user, entra_uid: 'entra-uid-1', upn: 'a@x.com' }

        it 'does not write to the user' do
          expect { get '/auth/entra_id/callback' }.not_to(change { user.reload.updated_at })
        end
      end
    end

    context 'when the provider does not give a UPN (developer fallback)' do
      let!(:user) { create :user }

      it 'leaves the session UPN nil and does not crash' do
        get '/auth/developer/callback', params: { uid: user.entra_uid }
        expect(session[:upn]).to be_nil
      end

      it 'does not change the stored UPN' do
        expect { get '/auth/developer/callback', params: { uid: user.entra_uid } }
          .not_to(change { user.reload.upn })
      end
    end
  end

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
end

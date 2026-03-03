# frozen_string_literal: true

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
end

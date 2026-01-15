# frozen_string_literal: true

RSpec.describe 'Sessions' do
  describe 'POST /logout' do
    subject(:submit) { post '/logout' }

    it 'redirects you to the shibboleth service provider logout and identity provider logout' do
      submit
      expect(response).to redirect_to(
        '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/saml2/idp/SingleLogoutService.php'
      )
    end
  end
end

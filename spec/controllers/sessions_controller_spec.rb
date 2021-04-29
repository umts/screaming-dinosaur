# frozen_string_literal: true

RSpec.describe SessionsController do
  describe 'DELETE #destroy' do
    subject(:submit) { delete :destroy }

    before { when_current_user_is :anyone }

    context 'when the Rails env is not "production"' do
      it 'redirects to dev_login' do
        submit
        expect(response).to redirect_to dev_login_path
      end

      it 'clears the session' do
        allow(session).to receive(:clear)
        submit
        expect(session).to have_received(:clear)
      end
    end

    context 'when the Rails env is "production"' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it 'redirects to something about Shibboleth' do
        submit
        expect(response).to redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
      end

      it 'clears the session' do
        allow(session).to receive(:clear)
        submit
        expect(session).to have_received(:clear)
      end
    end
  end

  describe 'GET #dev_login' do
    let :submit do
      get :dev_login
    end

    it 'assigns a rosters variable' do
      roster1 = create :roster
      roster2 = create :roster
      submit
      expect(assigns.fetch(:rosters)).to contain_exactly roster1, roster2
    end

    it 'renders the correct template' do
      submit
      expect(response).to render_template 'dev_login'
    end
  end

  describe 'POST #dev_login' do
    subject :submit do
      post :dev_login, params: { user_id: user.id, roster_id: roster.id }
    end

    let(:roster) { create :roster }
    let(:user) { roster_user(roster) }

    it 'creates a session for the user specified' do
      submit
      expect(session[:user_id]).to eql user.id.to_s
    end

    it 'redirects to the assignments path for the specified roster' do
      submit
      expect(response).to redirect_to roster_assignments_path(roster)
    end
  end

  describe 'GET #unauthenticated' do
    let :submit do
      get :unauthenticated
    end

    it 'renders the correct template' do
      expect(submit).to render_template :unauthenticated
    end
  end
end

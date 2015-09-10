require 'rails_helper'

describe SessionsController do
  describe 'DELETE #destroy' do
    before :each do
      @user = create :user
      when_current_user_is @user
    end
    let :submit do
      delete :destroy
    end
    context 'development' do
      before :each do
        expect(Rails.env)
          .to receive(:production?)
          .and_return false
      end
      it 'redirects to dev_login' do
        submit
        expect(response).to redirect_to dev_login_path
      end
      it 'clears the session' do
        expect_any_instance_of(ActionController::TestSession)
          .to receive :clear
        submit
      end
    end
    context 'production' do
      before :each do
        expect(Rails.env)
          .to receive(:production?)
          .and_return true
      end
      it 'redirects to something about Shibboleth' do
        submit
        expect(response).to redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
      end
      it 'clears the session' do
        expect_any_instance_of(ActionController::TestSession)
          .to receive :clear
        submit
      end
    end
  end

  describe 'GET #dev_login' do
    let :submit do
      get :dev_login
    end
    it 'assigns a users variable' do
      submit
      user_1 = create :user
      user_2 = create :user
      user_3 = create :user
      expect(assigns.fetch :users).to contain_exactly user_1, user_2, user_3
    end
    it 'renders the correct template' do
      submit
      expect(response).to render_template 'dev_login'
    end
  end
  
  describe 'POST #dev_login' do
    before :each do
      @user = create :user
    end
    let :submit do
      post :dev_login, user_id: @user.id
    end
    it 'creates a session for the user specified' do
      submit
      expect(session[:user_id]).to eql @user.id.to_s
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

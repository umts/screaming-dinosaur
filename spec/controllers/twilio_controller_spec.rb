require 'rails_helper'

describe TwilioController do
  describe 'GET #call, XML' do
    before :each do
      @user = create :user
      expect(Assignment)
        .to receive(:current)
        .and_return(create :assignment, user: @user)
    end
    let :submit do
      get :call, format: :xml
    end
    it 'sets the current on call user to the user variable' do
      submit
      expect(assigns.fetch :user).to eql @user
    end
    it 'renders the call template' do
      submit
      expect(response).to render_template :call
    end
  end

  describe 'GET #text, XML' do
    before :each do
      @user = create :user
      expect(Assignment)
        .to receive(:current)
        .and_return(create :assignment, user: @user)
      @body = 'message body'
    end
    let :submit do
      get :text, format: :xml, Body: @body
    end
    it 'sets the current on call user to the user variable' do
      submit
      expect(assigns.fetch :user).to eql @user
    end
    it 'passes the Body parameter through as a body instance variable' do
      submit
      expect(assigns.fetch :body).to eql @body
    end
    it 'renders the text template' do
      submit
      expect(response).to render_template :text
    end
  end
end

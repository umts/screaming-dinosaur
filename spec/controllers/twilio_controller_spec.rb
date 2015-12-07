require 'rails_helper'

describe TwilioController do
  describe 'GET #call, XML' do
    let :submit do
      get :call, format: :xml
    end
    context 'current assignment is present' do
      before :each do
        @user = create :user
        expect(Assignment)
          .to receive(:current)
          .and_return(create :assignment, user: @user)
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
    context 'no current assignment' do
      before :each do
        @user = create :user
        expect(Assignment)
          .to receive(:current)
          .and_return nil
        expect(User)
          .to receive(:fallback)
          .and_return @user
      end
      it 'sets the fallback user to the user variable' do
        submit
        expect(assigns.fetch :user).to eql @user
      end
      it 'renders the call template' do
        submit
        expect(response).to render_template :call
      end
    end
  end

  describe 'GET #text, XML' do
    before :each do
      @body = 'message body'
    end
    let :submit do
      get :text, format: :xml, Body: @body
    end
    context 'current assignment is present' do
      before :each do
        @user = create :user
        expect(Assignment)
          .to receive(:current)
          .and_return(create :assignment, user: @user)
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
    context 'no current assignment' do
      before :each do
        @user = create :user
        expect(Assignment)
          .to receive(:current)
          .and_return nil
        expect(User)
          .to receive(:fallback)
          .and_return @user
      end
      it 'sets the fallback user to the user variable' do
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
end

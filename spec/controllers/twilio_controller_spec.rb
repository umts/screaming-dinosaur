# frozen_string_literal: true

require 'rails_helper'

describe TwilioController do
  describe 'GET #call, XML' do
    let(:roster) { create :roster }
    let :submit do
      get :call, params: { roster_id: roster.id, format: :xml }
    end
    before :each do
      @user = create :user
      expect_any_instance_of(Roster)
        .to receive(:on_call_user)
        .and_return @user
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
      @body = 'message body'
      @roster = create :roster
      @user = create :user
      expect_any_instance_of(Roster)
        .to receive(:on_call_user)
        .and_return @user
    end
    let :submit do
      get :text, params: { format: :xml, Body: @body, roster_id: @roster.id }
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

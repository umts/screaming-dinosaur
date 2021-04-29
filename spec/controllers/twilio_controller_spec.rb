# frozen_string_literal: true

RSpec.describe TwilioController do
  let(:roster) { create :roster }
  let(:user) { roster_user(roster) }

  before do
    allow(Roster).to receive(:find_by).and_return roster
    allow(roster).to receive(:on_call_user).and_return user
  end

  describe 'GET #call, XML' do
    subject :submit do
      get :call, params: { roster_id: roster.id, format: :xml }
    end

    it 'sets the current on call user to the user variable' do
      submit
      expect(assigns.fetch(:user)).to eql user
    end

    it 'renders the call template' do
      submit
      expect(response).to render_template :call
    end
  end

  describe 'GET #text, XML' do
    subject :submit do
      get :text, params: { format: :xml, Body: body, roster_id: roster.id }
    end

    let(:body) { 'message body' }

    it 'sets the current on call user to the user variable' do
      submit
      expect(assigns.fetch(:user)).to eql user
    end

    it 'passes the Body parameter through as a body instance variable' do
      submit
      expect(assigns.fetch(:body)).to eql body
    end

    it 'renders the text template' do
      submit
      expect(response).to render_template :text
    end
  end
end

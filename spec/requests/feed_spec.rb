# frozen_string_literal: true

RSpec.describe 'Feeds' do
  describe 'GET /feed/:roster_id/:token' do
    subject(:call) { get "/feed/#{roster.slug}/#{token}" }

    let(:roster) { create :roster }
    let(:token) { 'sometoken' }

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with a calendar file' do
        call
        expect(response.media_type).to eq('text/calendar')
      end
    end

    context 'when logged in as a member of the roster using a calendar access token' do
      let(:token) { create(:user, rosters: [roster]).calendar_access_token }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with a calendar file' do
        call
        expect(response.media_type).to eq('text/calendar')
      end
    end
  end
end

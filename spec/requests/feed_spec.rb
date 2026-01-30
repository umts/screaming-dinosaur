# frozen_string_literal: true

RSpec.describe 'Feeds' do
  describe 'GET /feed/:roster_name/:token' do
    subject(:call) { get "/feed/#{roster.name.parameterize}/#{token}" }

    let(:roster) { create :roster }
    let(:token) { 'sometoken' }

    context 'when logged in as an unrelated user' do
      let(:current_user) { create :user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster user' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with a calendar file' do
        call
        expect(response.media_type).to eq('text/calendar')
      end
    end

    context 'when logged in as a roster user through a calendar access token' do
      let(:token) { create(:user, memberships: [build(:membership, roster:)]).calendar_access_token }

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

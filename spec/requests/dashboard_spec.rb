# frozen_string_literal: true

RSpec.describe 'Dashboard' do
  let(:user) { create :user }
  let(:roster) { user.rosters.first }

  describe 'GET /' do
    subject(:call) { get '/' }

    before { create_list :roster, 2 }

    context 'when not logged in' do
      it 'responds with an unauthorized status' do
        call
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when logged in as a roster-less user' do
      let(:current_user) { create :user }

      it 'redirects to all rosters' do
        call
        expect(response).to redirect_to(rosters_path)
      end
    end

    context 'when logged in as a user with only one roster' do
      let(:current_user) { create :user }
      let(:roster) { create :roster }

      before { create(:membership, roster:, user: current_user) }

      it 'redirects to that roster' do
        call
        expect(response).to redirect_to(roster_path(roster))
      end
    end

    context 'when logged in as a user with multiple rosters' do
      let(:current_user) { create :user }

      before { create_list :membership, 2, user: current_user }

      it 'redirects to all rosters' do
        call
        expect(response).to redirect_to(rosters_path)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe 'Dashboard' do
  let(:user) { create :user }
  let(:roster) { user.rosters.first }

  describe 'GET /' do
    subject(:call) { get '/' }

    before { create_list(:roster, 2) }

    context 'when the current user does not have access to any rosters' do
      let(:current_user) { create(:user) }

      it 'redirects to all rosters' do
        call
        expect(response).to redirect_to(rosters_path)
      end
    end

    context 'when the current user has access to one roster' do
      let(:current_user) { create(:user) }
      let!(:roster) { create(:membership, user: current_user).roster }

      it "redirects to that roster's assignments" do
        call
        expect(response).to redirect_to(roster_assignments_path(roster))
      end
    end

    context 'when the current user has access to multiple rosters' do
      let(:current_user) { create(:user) }

      before { create_list(:membership, 2, user: current_user) }

      it 'redirects to all rosters' do
        call
        expect(response).to redirect_to(rosters_path)
      end
    end
  end
end

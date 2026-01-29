# frozen_string_literal: true

RSpec.describe 'Dashboards' do
  let(:user) { create :user }
  let(:roster) { user.rosters.first }

  describe 'GET /' do
    subject(:call) { get '/' }

    let(:current_user) { user }

    context 'when user has one roster' do
      it 'redirects to roster assignments' do
        call
        expect(response).to redirect_to(roster_assignments_path(roster))
      end
    end

    context 'when user has multiple rosters' do
      before do
        user.rosters << (create :roster)
      end

      it 'shows dashboard' do
        call
        expect(response).to redirect_to rosters_path
      end
    end
  end
end

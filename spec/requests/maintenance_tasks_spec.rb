# frozen_string_literal: true

RSpec.describe 'Maintenance Tasks' do
  describe 'GET /maintenance_tasks' do
    subject(:call) { get '/maintenance_tasks' }

    context 'when logged in as a roster admin' do
      let(:current_user) { create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin' do
      let(:current_user) { create(:user, admin: true) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end
end

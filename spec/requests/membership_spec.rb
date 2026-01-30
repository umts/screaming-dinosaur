# frozen_string_literal: true

RSpec.describe 'Memberships' do
  describe 'POST /rosters/:roster_id/memberships' do
    subject(:submit) { post "/rosters/#{roster.id}/memberships", params: { membership: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as a roster user' do
      let(:current_user) { create(:membership, roster:, admin: false).user }
      let(:attributes) { { user_id: nil } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create(:membership, roster:, admin: true).user }

      context 'with valid attributes' do
        let!(:user) { create :user }
        let(:attributes) { { user_id: user.id, admin: true } }

        it 'redirects to roster index' do
          submit
          expect(response).to redirect_to roster_memberships_path(roster)
        end

        it 'creates a memberships' do
          expect { submit }.to change(Membership, :count).by(1)
        end

        it 'creates a memberships with the correct attributes' do
          submit
          expect(Membership.last).to have_attributes(attributes)
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { { user_id: nil, admin: false } }

        it 'redirects to roster index' do
          submit
          expect(response).to redirect_to roster_memberships_path(roster)
        end

        it 'does not create a memberships' do
          expect { submit }.not_to change(Membership, :count)
        end
      end
    end
  end

  describe 'PATCH /memberships/:id' do
    subject(:submit) { patch "/memberships/#{membership.id}", params: { membership: attributes } }

    let(:roster) { create :roster }
    let(:membership) { create :membership, roster: }

    context 'when logged in as a roster user' do
      let(:current_user) { create(:membership, roster:, admin: false).user }
      let(:attributes) { { user_id: nil } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create(:membership, roster:, admin: true).user }

      context 'with valid attributes' do
        let(:attributes) { { admin: true } }

        it 'redirects to roster index' do
          submit
          expect(response).to redirect_to roster_memberships_path(roster)
        end

        it 'updates the memberships with the correct attributes' do
          submit
          expect(membership.reload).to have_attributes(attributes)
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { { user_id: nil } }

        it 'redirects to roster index' do
          submit
          expect(response).to redirect_to roster_memberships_path(roster)
        end

        it 'does not update the memberships' do
          expect { submit }.not_to(change { membership.reload.attributes })
        end
      end
    end
  end

  describe 'DELETE /memberships/:id' do
    subject(:submit) { delete "/memberships/#{membership.id}" }

    let(:roster) { create :roster }
    let(:membership) { create :membership, roster: }

    context 'when logged in as a roster user' do
      let(:current_user) { create(:membership, roster:, admin: false).user }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create(:membership, roster:, admin: true).user }

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'removes the memberships' do
        submit
        expect(Membership.find_by(id: membership.id)).to be_nil
      end
    end
  end
end

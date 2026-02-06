# frozen_string_literal: true

RSpec.describe 'Memberships' do
  shared_context 'with valid attributes' do
    let(:attributes) { { user_id: create(:user).id, admin: true } }
  end

  shared_context 'with invalid attributes' do
    let(:attributes) { { user_id: nil } }
  end

  describe 'POST /rosters/:roster_id/memberships' do
    subject(:submit) { post "/rosters/#{roster.id}/memberships", params: { membership: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with valid attributes'

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'creates a memberships' do
        expect { submit }.to change(Membership, :count).by(1)
      end

      it 'creates a memberships with the correct attributes' do
        submit
        expect(Membership.last).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with invalid attributes'

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'does not create a membership' do
        expect { submit }.not_to change(Membership, :count)
      end
    end
  end

  describe 'PATCH /memberships/:id' do
    subject(:submit) { patch "/memberships/#{membership.id}", params: { membership: attributes } }

    let(:roster) { create :roster }
    let(:membership) { create :membership, roster: }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with valid attributes'

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'updates the memberships with the correct attributes' do
        submit
        expect(membership.reload).to have_attributes(attributes)
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with invalid attributes'

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'does not update the memberships' do
        expect { submit }.not_to(change { membership.reload.attributes })
      end
    end
  end

  describe 'DELETE /memberships/:id' do
    subject(:submit) { delete "/memberships/#{membership.id}" }

    let(:roster) { create :roster }
    let(:membership) { create :membership, roster: }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'redirects to roster index' do
        submit
        expect(response).to redirect_to roster_memberships_path(roster)
      end

      it 'removes the memberships' do
        submit
        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

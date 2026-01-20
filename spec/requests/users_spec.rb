# frozen_string_literal: true

RSpec.describe 'Users' do
  describe 'GET /rosters/:id/users' do
    subject(:call) { get "/rosters/#{roster.id}/users" }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      before { login_as Membership.create(user: (create :user), roster: roster, admin: false).user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:roster) { create :roster }

      before { login_as Membership.create(user: (create :user), roster: roster, admin: true).user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/users/new' do
    subject(:call) { get "/rosters/#{roster.id}/users/new" }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      before { login_as Membership.create(user: (create :user), roster: roster, admin: false).user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:roster) { create :roster }

      before do
        login_as Membership.create(user: (create :user), roster: roster, admin: true).user
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:id/users' do
    subject(:submit) { post "/rosters/#{roster.id}/users", params: }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      before { login_as Membership.create(user: (create :user), roster: roster, admin: false).user }

      let(:params) { nil }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

      context 'with valid attributes' do
        let(:attributes) { attributes_for :user }
        let(:params) { { user: attributes.merge(roster_ids: [roster.id]), roster_id: roster.id } }

        it 'responds successfully' do
          submit
          expect(response).to redirect_to(roster_users_path(roster))
        end

        it 'creates a user' do
          expect { submit }.to change(User, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        let(:params) { { user: (attributes_for :user) } }

        it 'response with unprocessable content' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe 'GET /rosters/:id/users/:user_id/edit' do
    subject(:call) { get "/rosters/#{roster.id}/users/#{user.id}/edit" }

    let(:user) { create :user }
    let(:roster) { user.rosters.first }

    context 'when logged in as another user' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before do
        login_as create(:user, memberships: [build(:membership, roster:, admin: true)])
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as the user themself' do
      before do
        login_as user
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /rosters/:id/users/:user_id' do
    subject(:submit) { patch "/rosters/#{roster.id}/users/#{user.id}", params: { user: attributes } }

    let(:user) { create :user }
    let(:roster) { user.rosters.first }
    let(:attributes) { attributes_for :user }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as the roster admin' do
      before do
        login_as Membership.create(user: (create :user), roster: roster, admin: true).user
      end

      context 'with valid attributes' do
        it 'responds successfully' do
          submit
          expect(response).to redirect_to(roster_users_path(roster))
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { { phone: '777' } }

        it 'responds with unprocessable entity' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context 'when logged in a different roster admin' do
      before do
        login_as Membership.create(user: (create :user), roster: (create :roster), admin: true).user
      end

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as the user themself' do
      before do
        login_as user
      end

      context 'with valid attributes' do
        it 'responds successfully' do
          submit
          expect(response).to redirect_to(roster_assignments_path(roster))
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { { phone: '777' } }

        it 'responds with unprocessable entity' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe 'POST /rosters/:id/users/transfer' do
    subject(:call) { post "/rosters/#{roster.id}/users/transfer", params: { id: user.id } }

    let(:user) { create :user }
    let(:roster) { create :roster }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when you are not a roster admin' do
      before { set_user create(:membership, roster:, admin: false).user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before do
        login_as Membership.create(user: (create :user), roster: roster, admin: true).user
        user.memberships.delete_all
      end

      it 'responds successfully' do
        expect { call }.to change(roster.users, :count).by(1)
      end

      it 'adds the user to the roster' do
        call
        expect(roster.users).to include(user)
      end
    end
  end
end

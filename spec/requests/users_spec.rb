# frozen_string_literal: true

RSpec.describe 'Users' do
  describe 'GET /users' do
    subject(:call) { get '/users' }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: false).user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:roster) { create :roster }

      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: true).user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET users/new' do
    subject(:call) { get '/users/new' }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: false).user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:roster) { create :roster }

      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: true).user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST users' do
    subject(:submit) { post '/users', params: }

    let(:roster) { create :roster }

    context 'when logged in as a roster member' do
      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: false).user }

      let(:params) { nil }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      context 'with valid attributes' do
        let(:attributes) { attributes_for :user }
        let(:params) { { user: attributes } }

        it 'responds successfully' do
          submit
          expect(response).to redirect_to(users_path)
        end

        it 'creates a user' do
          expect { submit }.to change(User, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        let(:params) { { user: (attributes_for :user).merge(phone: 777) } }

        it 'response with unprocessable content' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe 'GET /users/:user_id/edit' do
    subject(:call) { get "/users/#{user.id}/edit" }

    let(:user) { create :user }
    let(:roster) { user.rosters.first }

    context 'when logged in as another user' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as the user themself' do
      let(:current_user) { user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /users/:user_id' do
    subject(:submit) { patch "/users/#{user.id}", params: { user: attributes } }

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
      let(:current_user) { Membership.create(user: (create :user), roster: roster, admin: true).user }

      context 'with valid attributes' do
        it 'responds successfully' do
          submit
          expect(response).to redirect_to(users_path)
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
      let(:current_user) { Membership.create(user: (create :user), roster: (create :roster), admin: true).user }

      it 'responds successfully' do
        submit
        expect(response).to redirect_to(users_path)
      end
    end

    context 'when logged in as the user themself' do
      let(:current_user) { user }

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
end

# frozen_string_literal: true

RSpec.describe 'Users' do
  describe 'GET /rosters/:id/users' do
    subject(:call) { get "/rosters/#{roster.id}/users" }

    let(:roster) { create :roster }

    context 'when you are not a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: false).user }

      it 'responds with an unauthorized status code' do
        call
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when you are a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: true).user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/users/new' do
  end

  describe 'POST /rosters/:id/users' do
    subject(:submit) { post "/rosters/#{roster.id}/users", params: { user: attributes } }

    let(:roster) { create :roster }

    context 'when you are not a roster admin' do
      let(:attributes) { nil }

      before { when_current_user_is create(:membership, roster:, admin: false).user }

      it 'responds with an unauthorized status code' do
        submit
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a user' do
        expect { submit }.not_to change(User, :count)
      end
    end

    context 'when you are a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: true).user }

      context 'with invalid attributes' do
        let(:attributes) { { phone: 'not a phone number' } }

        it 'responds with an unprocessable content status code' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'does not create a user' do
          expect { submit }.not_to change(User, :count)
        end
      end

      context 'with valid attributes' do
        let(:attributes) do
          { first_name: 'Bobo',
            last_name: 'Test',
            spire: '12345678@umass.edu',
            email: 'bobo@test.com',
            phone: '(413) 586-1021',
            active: true,
            reminders_enabled: true,
            change_notifications_enabled: true }
        end

        it 'redirects you to all roster users' do
          submit
          expect(response).to redirect_to(roster_users_path(roster))
        end

        it 'creates a user' do
          expect { submit }.to change(User, :count).by(1)
        end

        it 'creates a user with the given attributes' do
          submit
          expect(User.last).to have_attributes(attributes)
        end

        it 'attaches the user to the current roster' do
          submit
          expect(User.last.memberships).to contain_exactly(have_attributes(roster_id: roster.id, admin: false))
        end
      end
    end
  end

  describe 'GET /users/:id/edit' do
  end

  describe 'PATCH /users/:id' do
    context 'when you are a roster admin' do
      context 'with valid attributes' do
        let(:attributes) { user_attributes.merge(memberships_attributes) }
        let(:user_attributes) do
          { first_name: 'Bobo',
            last_name: 'Test',
            spire: '12345678@umass.edu',
            email: 'bobo@test.com',
            phone: '(413) 586-1021',
            active: true,
            reminders_enabled: true,
            change_notifications_enabled: true }
        end
        let(:memberships_attributes) do
          {}
        end
      end
    end
  end

  describe 'DELETE /users/:id' do
  end

  describe 'POST /rosters/:id/users/transfer' do
  end
end

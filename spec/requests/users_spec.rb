# frozen_string_literal: true

RSpec.describe 'Users' do
  shared_context 'when you are the roster admin' do
    let(:admin) do
      admin = User.new(first_name: 'Bobo',
                       last_name: 'Test',
                       email: 'why@umass.edu',
                       phone: '413-454-7890',
                       spire: '87654321@umass.edu')
      admin.memberships.build(roster: roster, admin: true)
      admin.save!
      admin
    end

    before { set_user admin }
  end

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

    include_context 'when you are the roster admin' do
      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/users/new' do
    subject(:call) { get "/rosters/#{roster.id}/users" }

    let(:roster) { create :roster }

    context 'when you are not a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: false).user }

      it 'responds with an unauthorized status code' do
        call
        expect(response).to have_http_status(:unauthorized)
      end
    end

    include_context 'when you are the roster admin' do
      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:id/users' do
    subject(:submit) { post "/rosters/#{roster.id}/users", params: { user: attributes } }

    let(:roster) { create :roster }
    let(:user) { create user }

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

    include_context 'when you are the roster admin' do
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
    subject(:call) { get "/users/#{user.id}/edit" }

    let(:roster) { create :roster }
    let(:user) { create(:membership, roster: roster).user }
    # let(:edit_user) { create(:membership, roster:).user }

    context 'when you are not a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: false).user }

      it 'responds with an unauthorized status code' do
        call
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when you are a roster admin' do
      include_context 'when you are the roster admin'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when you are the user themselves' do
      before { when_current_user_is user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /users/:id' do
    subject(:submit) { patch "/users/#{user.id}", params: { user: attributes, roster_id: roster.id } }

    let(:user) { create :user }
    let(:roster) { user.rosters.first }
    let(:roster2) { create :roster, name: 'Second Roster' }
    let(:second_membership_id) { Membership.create(user:, roster: roster2).id }

    context 'when you are a roster admin' do
      before { roster.update(name: 'First Roster') }

      include_context 'when you are the roster admin'

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
          { memberships_attributes: { '0': { id: user.memberships.first.id, roster_id: roster.id, _destroy: false },
                                      '1': { id: second_membership_id, roster_id: roster2.id, _destroy: true } } }
        end

        it 'redirects to the roster index' do
          submit
          expect(response).to redirect_to(roster_users_path(roster))
        end

        it 'keeps a membership' do
          submit
          expect(user.rosters).to include(roster)
        end

        it 'removes a membership' do
          submit
          expect(user.rosters).not_to include(roster_2)
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { { phone: 'not a phone number' } }

        it 'responds with a unprocessable content status code' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context 'when you are not a roster admin' do
      before { when_current_user_is create(:membership, roster:, admin: false).user }

      let(:attributes) { nil }

      it 'responds with an unauthorized status code' do
        submit
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /users/:id' do
    return
  end

  describe 'POST /rosters/:id/users/transfer' do
    return
  end
end

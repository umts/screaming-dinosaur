# frozen_string_literal: true

RSpec.describe 'Users' do
  shared_context 'with invalid attributes' do
    let(:attributes) { { first_name: nil, last_name: nil } }
  end

  describe 'GET /users' do
    subject(:call) { get '/users' }

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin' do
      let(:current_user) { create :user, admin: true }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /users/new' do
    subject(:call) { get '/users/new' }

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin' do
      let(:current_user) { create :user, admin: true }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /users/:id/edit' do
    subject(:call) { get "/users/#{user.id}/edit" }

    let(:user) { create :user }

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin' do
      let(:current_user) { create :user, admin: true }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as the user to edit' do
      let(:current_user) { user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /users' do
    subject(:submit) { post '/users', params: { user: attributes } }

    context 'when logged in as a roster admin' do
      let(:attributes) do
        { first_name: 'Bobo',
          last_name: 'Test',
          email: 'bobo@test.com',
          phone: '(413) 545-0056' }
      end

      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin with valid attributes' do
      let(:current_user) { create :user, admin: true }
      let(:attributes) do
        { first_name: 'Bobo',
          last_name: 'Test',
          email: 'bobo@test.com',
          phone: '(413) 545-0056' }
      end

      it 'redirects to all users' do
        submit
        expect(response).to redirect_to(users_path)
      end

      it 'creates a user' do
        expect { submit }.to change(User, :count).by(1)
      end

      it 'creates a user with the given attributes' do
        submit
        expect(User.last).to have_attributes(attributes)
      end
    end

    context 'when logged in as a system admin with invalid attributes' do
      include_context 'with invalid attributes'

      let(:current_user) { create :user, admin: true }

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /users/:id' do
    subject(:submit) { patch "/users/#{user.id}", params: { user: attributes } }

    let(:user) { create :user }

    context 'when logged in as a roster admin' do
      let(:attributes) do
        { first_name: 'Bobo',
          last_name: 'Test',
          email: 'bobo@test.com',
          phone: '(413) 545-0056' }
      end

      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin with valid attributes' do
      let(:current_user) { create :user, admin: true }
      let(:attributes) do
        { first_name: 'Bobo',
          last_name: 'Test',
          email: 'bobo@test.com',
          phone: '(413) 545-0056' }
      end

      it 'redirects to the edit user page' do
        submit
        expect(response).to redirect_to(edit_user_path(user))
      end

      it 'updates the user with the given attributes' do
        submit
        expect(user.reload).to have_attributes(attributes)
      end
    end

    context 'when logged in as a system admin with invalid attributes' do
      include_context 'with invalid attributes'

      let(:current_user) { create :user, admin: true }

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when logged in as the user to edit with valid attributes' do
      let(:current_user) { user }
      let(:attributes) do
        { first_name: 'Bobo',
          last_name: 'Test',
          email: 'bobo@test.com',
          phone: '(413) 545-0056' }
      end

      it 'redirects to the edit user page' do
        submit
        expect(response).to redirect_to(edit_user_path(user))
      end

      it 'updates the user with the given attributes' do
        submit
        expect(user.reload).to have_attributes(attributes)
      end
    end

    context 'when logged in as the user to edit with invalid attributes' do
      include_context 'with invalid attributes'

      let(:current_user) { user }

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when logged in as the user to edit with an admin update' do
      let(:current_user) { user }
      let(:attributes) { { admin: true } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as the user to edit with an active update' do
      let(:current_user) { user }
      let(:attributes) { { active: false } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

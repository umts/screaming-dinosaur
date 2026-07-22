# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin' do
  describe 'GET /admin/users' do
    subject(:call) { get '/admin/users' }

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

  describe 'GET /admin' do
    subject(:call) { get '/admin' }

    context 'when logged in as a system admin' do
      let(:current_user) { create(:user, admin: true) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/users/:id' do
    subject(:call) { get "/admin/users/#{user.id}" }

    let(:user) { create(:user) }

    context 'when logged in as a system admin' do
      let(:current_user) { create(:user, admin: true) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/users/:id/edit' do
    subject(:call) { get "/admin/users/#{user.id}/edit" }

    let(:user) { create(:user) }

    context 'when logged in as a system admin' do
      let(:current_user) { create(:user, admin: true) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /admin/users/:id' do
    subject(:call) { patch "/admin/users/#{user.id}", params: { user: attributes } }

    let(:user) { create(:user, first_name: 'Old', admin: false) }

    context 'when logged in as a system admin' do
      let(:current_user) { create(:user, admin: true) }
      let(:attributes) { { first_name: 'New' } }

      it 'redirects to the user' do
        call
        expect(response).to redirect_to(admin_user_path(user))
      end

      it 'updates the permitted attribute' do
        call
        expect(user.reload.first_name).to eq('New')
      end
    end

    context 'when a system admin submits guarded attributes' do
      let(:current_user) { create(:user, admin: true) }
      let(:attributes) { { admin: true, entra_uid: 'hijacked' } }

      it 'ignores admin and entra_uid' do
        call
        expect(user.reload).to have_attributes(admin: false, entra_uid: user.entra_uid)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin' do
  describe 'GET /admin/users' do
    subject(:call) { get '/admin/users' }

    context 'when logged out' do
      it 'redirects to the root path' do
        call
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create(:user, memberships: [build(:membership, admin: true)]) }

      it 'redirects to the root path' do
        call
        expect(response).to redirect_to(root_path)
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
end

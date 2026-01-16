# frozen_string_literal: true

RSpec.describe 'Memberships' do
  describe 'GET /rosters/:roster_id/memberships' do
    subject(:call) { post "/rosters/#{roster.id}/memberships", params: { user_id: user.id } }

    let(:roster) { create :roster }
    let(:user) { create :user }

    before do
      admin_membership = Membership.create(roster: roster, admin: true, user: (create :user))
      set_user admin_membership.user
    end

    it 'redirects to roster index' do
      call
      expect(response).to redirect_to roster_users_path(roster)
    end

    it 'creates a new membership' do
      call
      expect(Membership.last.user).to eq user
    end
  end

  describe 'DELETE /rosters/:roster_id/memberships/:id' do
    subject(:submit) { delete "/rosters/#{roster.id}/memberships/#{membership.id}" }

    let(:roster) { create :roster }
    let(:user) { create :user }
    let(:membership) { create :membership, user: user, roster: roster }

    before do
      admin_membership = Membership.create(roster: roster, admin: true, user: (create :user))
      set_user admin_membership.user
    end

    it 'redirects to roster index' do
      submit
      expect(response).to redirect_to roster_users_path(roster)
    end

    it 'removes the membership' do
      submit
      expect(Membership.find_by(roster: roster, user: user)).to be_nil
    end
  end
end

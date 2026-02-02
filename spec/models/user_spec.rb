# frozen_string_literal: true

RSpec.describe User do
  let(:user) { create :user }

  describe 'full_name' do
    subject { user.full_name }

    it { is_expected.to eq [user.first_name, user.last_name].join(' ') }
  end

  describe 'proper name' do
    subject { user.proper_name }

    it { is_expected.to eq [user.last_name, user.first_name].join(', ') }
  end

  describe 'admin_in?' do
    let(:roster) { create :roster }

    context 'with admin membership in the roster' do
      before { create :membership, roster:, user:, admin: true }

      it('returns true') { expect(user).to be_admin_in(roster) }
    end

    context 'with non-admin membership in the roster' do
      before { create :membership, roster:, user:, admin: false }

      it('returns false') { expect(user).not_to be_admin_in(roster) }
    end
  end

  describe 'admin?' do
    let(:membership) { create :membership }
    let(:admin_membership) { create :membership, admin: true }

    context 'with admin membership in any roster' do
      it('returns true') { expect(admin_membership.user).to be_admin }
    end

    context 'without any admin memberships' do
      it('returns false') { expect(membership.user).not_to be_admin }
    end
  end
end

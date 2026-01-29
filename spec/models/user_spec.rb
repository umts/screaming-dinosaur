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

    context 'with admin memberships in the roster' do
      before { create :membership, roster:, user:, admin: true }

      it('returns true') { expect(user).to be_admin_in(roster) }
    end

    context 'with non-admin memberships in the roster' do
      before { create :membership, roster:, user:, admin: false }

      it('returns false') { expect(user).not_to be_admin_in(roster) }
    end
  end

  describe 'admin?' do
    let(:membership) { create :membership }
    let(:admin_membership) { create :membership, admin: true }

    context 'with admin memberships in any roster' do
      it('returns true') { expect(admin_membership.user).to be_admin }
    end

    context 'without any admin memberships' do
      it('returns false') { expect(membership.user).not_to be_admin }
    end
  end

  describe 'being deactivated' do
    let(:future_assignment) { create :assignment, start_date: Date.tomorrow }

    it 'destroys future assignments for users' do
      future_assignment.user.update(active: false)
      expect(user.assignments).to be_empty
    end
  end

  describe '#valid?' do
    subject(:call) { user.valid? }

    context 'when logged in as the subject and attempting deactivation' do
      let(:current_user) { user }
      let(:user) { create :user }

      before { user.active = false }

      it 'does not allow you to deactivate yourself' do
        expect(call).to be(false)
      end

      it 'adds a helpful error message' do
        call
        expect(user.errors[:base]).to include('You may not deactivate yourself')
      end
    end
  end
end

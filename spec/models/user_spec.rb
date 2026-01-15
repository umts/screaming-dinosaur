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

  describe 'being deactivated' do
    let(:future_assignment) { create :assignment, start_date: Date.tomorrow }

    it 'destroys future assignments for users' do
      future_assignment.user.update(active: false)
      expect(user.assignments).to be_empty
    end
  end

  describe 'phone change notification for fallback users' do
    let(:fallback_user) { create :user }
    let(:roster1) { create :roster, fallback_user: }
    let(:roster2) { create :roster, fallback_user: }
    let(:admin1) { create :user }
    let(:admin2) { create :user }

    before do
      admin1.memberships.create(roster: roster1, admin: true)
      admin2.memberships.create(roster: roster2, admin: true)
      ActionMailer::Base.deliveries.clear
    end

    it 'sends notification to all affected rosters when fallback user phone changes' do
      expect do
        fallback_user.update(phone: '+15551234567')
      end.to change { ActionMailer::Base.deliveries.size }.by 2
    end

    it 'does not send notification when phone does not change' do
      expect do
        fallback_user.update(first_name: 'New Name')
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end

    it 'does not send notification when user is not a fallback user' do
      regular_user = create :user

      expect do
        regular_user.update(phone: '+15551234567')
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end

    it 'does not send notification to rosters without admins' do
      roster_without_admins = create :roster, fallback_user:

      expect do
        fallback_user.update(phone: '+15551234567')
      end.to change { ActionMailer::Base.deliveries.size }.by 2
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:roster) }
  end

  describe 'validations' do
    subject { build :membership }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:roster_id) }
  end

  describe '#destroy' do
    subject(:call) { membership.destroy }

    context 'when the user has existing assignments' do
      let(:membership) { create :membership }
      let!(:past_assignments) do
        [create(:assignment, roster: membership.roster, user: membership.user,
                             start_date: 4.days.ago, end_date: 3.days.ago),
         create(:assignment, roster: membership.roster, user: membership.user,
                             start_date: 2.days.ago, end_date: 1.day.ago)]
      end
      let!(:future_assignments) do
        [create(:assignment, roster: membership.roster, user: membership.user,
                             start_date: Date.tomorrow, end_date: 2.days.from_now),
         create(:assignment, roster: membership.roster, user: membership.user,
                             start_date: 3.days.from_now, end_date: 4.days.from_now)]
      end

      it 'leaves past assignment untouched for the associated user and roster' do
        call
        expect(past_assignments.map { |assignment| Assignment.find_by(id: assignment.id) }).to all(be_present)
      end

      it 'destroys all future assignments for the associated user and roster' do
        call
        expect(future_assignments.map { |assignment| Assignment.find_by(id: assignment.id) }).to all(be_nil)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe Membership do
  describe 'at least one admin validation' do
    it 'allows adding an admin' do
      membership = create :membership
      membership.assign_attributes(admin: true)
      expect(membership).to be_valid
    end

    it 'allows demoting an admin who is not the sole admin' do
      membership = create :membership, admin: true
      create :membership, admin: true, roster: membership.roster
      membership.assign_attributes(admin: false)
      expect(membership).to be_valid
    end

    it 'prohibits demoting the sole admin' do
      membership = create :membership, admin: true
      membership.assign_attributes(admin: false)
      expect(membership).not_to be_valid
    end
  end

  describe '#destroy' do
    subject(:call) { membership.destroy }

    let(:user) { create :user }
    let(:roster) { create :roster }
    let!(:membership) { create :membership, user:, roster:, admin: false }
    let!(:assignments) do
      [create(:assignment, roster:, user:, start_date: Date.tomorrow, end_date: 2.days.from_now),
       create(:assignment, roster:, user:, start_date: 3.days.from_now, end_date: 4.days.from_now)]
    end

    it 'destroys all future assignments for the associated user and roster' do
      call
      expect(assignments.map { |assignment| Assignment.find_by(id: assignment.id) }).to all(be_nil)
    end
  end
end

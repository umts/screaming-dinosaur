# frozen_string_literal: true

require 'spec_helper'

describe User do
  let(:user) { create :user }
  describe 'full_name' do
    it 'returns first name followed by last name' do
      expect(user.full_name).to eql [user.first_name, user.last_name].join(' ')
    end
  end
  describe 'proper name' do
    it 'returns first name followed by last name' do
      expect(user.proper_name)
        .to eql [user.last_name, user.first_name].join(', ')
    end
  end
  describe 'admin_in?' do
    let(:roster) { create :roster }
    context 'membership has admin true' do
      it 'returns true' do
        create :membership, roster: roster, user: user,
                            admin: true
        expect(user).to be_admin_in(roster)
      end
    end
    context 'membership has admin false' do
      it 'returns false' do
        create :membership, roster: roster, user: user,
                            admin: false
        expect(user).not_to be_admin_in(roster)
      end
    end
  end
  describe 'admin?' do
    let(:membership) { create :membership }
    let(:admin_membership) { create :membership, admin: true }
    context 'admin in any roster' do
      it 'returns true' do
        expect(admin_membership.user).to be_admin
      end
    end
    context 'admin in no rosters' do
      it 'returns false' do
        expect(membership.user).not_to be_admin
      end
    end
  end
  describe 'being deactivated' do
    let(:future_assignment) { create :assignment, start_date: Date.tomorrow }
    it 'destroys future assignments for users' do
      user = future_assignment.user
      user.active = false
      user.save
      expect(user.assignments).to be_empty
    end
  end
end

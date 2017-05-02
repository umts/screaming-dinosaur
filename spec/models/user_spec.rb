# frozen_string_literal: true

require 'rails_helper'

describe User do
  describe 'full_name' do
    it 'returns first name followed by last name' do
      user = create :user
      expect(user.full_name).to eql [user.first_name, user.last_name].join(' ')
    end
  end
  describe 'proper name' do
    it 'returns first name followed by last name' do
      user = create :user
      expect(user.proper_name)
        .to eql [user.last_name, user.first_name].join(', ')
    end
  end
  describe 'admin_in?' do
    let(:roster) { create :roster }
    let(:user) { create :user }
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
end

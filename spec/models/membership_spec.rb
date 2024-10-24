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
end

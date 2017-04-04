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
  describe 'self.fallback' do
    it 'returns the fallback user if one is present' do
      fallback = create :user, is_fallback: true
      expect(User.fallback).to eql fallback
    end
    it 'returns nil if no fallback user is present' do
      expect(User.fallback).to be nil
    end
  end
end

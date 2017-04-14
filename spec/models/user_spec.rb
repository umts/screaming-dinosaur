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
end

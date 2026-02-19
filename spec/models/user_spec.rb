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

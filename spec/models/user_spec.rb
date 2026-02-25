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

  describe '#save' do
    subject(:call) { user.save }

    context 'when the user is a new user' do
      let(:user) { build :user }

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end

    context 'when the user is a fallback user and their phone changes' do
      let(:user) { create :user }
      let(:roster) { create :roster, fallback_user: user }

      before do
        create(:membership, roster:, admin: true)
        roster
        user.phone = '14135551234'
      end

      it 'sends a notification' do
        expect { call }.to have_enqueued_email(RosterMailer, :fallback_number_changed)
          .with(params: { roster: roster }, args: [])
      end
    end

    context 'when the user is a fallback user but their phone does not change' do
      let(:user) { create :user }
      let(:roster) { create :roster, fallback_user: user }

      before do
        create(:membership, roster:, admin: true)
        roster
        user.first_name = 'NewName'
      end

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end

    context 'when the user is a fallback user with no admins and their phone changes' do
      let(:user) { create :user }
      let(:roster) { create :roster, fallback_user: user }

      before do
        roster
        user.phone = '14135551234'
      end

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end

    context 'when the user is not a fallback user and their phone changes' do
      let(:user) { create :user }

      before { user.phone = '14135551234' }

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end
  end
end

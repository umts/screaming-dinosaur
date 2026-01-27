# frozen_string_literal: true

RSpec.describe Roster do
  include ActiveSupport::Testing::TimeHelpers

  describe 'next_rotation_start_date' do
    subject(:result) { roster.next_rotation_start_date }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }

    context 'with existing assignments' do
      before do
        create :assignment, roster:, end_date: 1.week.from_now
      end

      it 'returns the day after the last assignment ends' do
        expect(result).to eq 8.days.since.to_date
      end
    end

    context 'with no existing assignments' do
      it 'returns the upcoming Friday' do
        travel_to Date.parse('Monday, May 8th, 2017')
        expect(result).to eq Date.parse('Friday, May 12th, 2017')
      end
    end
  end

  describe 'on_call_user' do
    subject(:result) { roster.on_call_user }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }
    let(:assignment) { create :assignment, roster: }

    context 'when there is a current assignment' do
      before do
        assignments = roster.assignments
        allow(roster).to receive(:assignments).and_return(assignments)
        allow(assignments).to receive(:current).and_return(assignment)
      end

      it 'returns the user of the current assignment' do
        expect(result).to eql assignment.user
      end
    end

    context "when there isn't a current assignment" do
      it 'returns the fallback user' do
        expect(result).to eql fallback_user
      end
    end
  end

  describe 'user_options' do
    let(:roster) { create :roster }
    let!(:admins) { [roster_admin(roster)] }
    let!(:non_admins) { [roster_user(roster)] }
    let(:call) { roster.user_options }

    it 'has admins in the "Admins"' do
      expect(call.fetch('Admins'))
        .to match_array(admins.map { |a| [a.full_name, a.id] })
    end

    it 'has non-admins in the "Non-Admins"' do
      expect(call.fetch('Non-Admins'))
        .to match_array(non_admins.map { |na| [na.full_name, na.id] })
    end
  end

  describe '#uncovered_dates_between' do
    subject(:call) { roster.uncovered_dates_between(start_date, end_date) }

    let(:roster) { create :roster }
    let(:start_date) { Time.zone.today }
    let(:end_date) { 1.week.from_now }

    before { create :assignment, roster:, start_date: 1.day.from_now, end_date: 6.days.from_now }

    it 'returns the dates with no assignments between the given start and end date' do
      expect(call).to eq [Time.zone.today.to_date, 7.days.from_now.to_date]
    end
  end

  describe '#switchover_time' do
    subject(:call) { roster.switchover_time }

    context 'with a blank switchover' do
      let(:roster) { build :roster, switchover: nil }

      it { is_expected.to be_nil }
    end

    context 'with a switchover' do
      let(:switchover) { (12 * 60) + 34 } # 12:34 PM
      let(:roster) { build :roster, switchover: }

      it 'is today' do
        expect(call.to_date).to eq(Time.zone.today)
      end

      it 'is the correct time' do
        expect(call.to_fs(:time)).to eq('12:34')
      end
    end
  end

  describe '#save' do
    let(:roster) { create :roster }
    let(:admin) { create :user }
    let(:old_fallback_user) { create :user }
    let(:new_fallback_user) { create :user }

    before do
      admin.memberships.create(roster:, admin: true)
      roster.update(fallback_user: old_fallback_user)
    end

    it 'sends notification when fallback_user_id changes' do
      expect do
        roster.update(fallback_user: new_fallback_user)
      end.to have_enqueued_email(RosterMailer, :fallback_number_changed)
    end

    it 'does not send notification when fallback_user_id does not change' do
      expect do
        roster.update(name: 'New Name')
      end.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
    end

    it 'does not send notification when roster has no admins' do
      roster_without_admins = create :roster, fallback_user: old_fallback_user

      expect do
        roster_without_admins.update(fallback_user: new_fallback_user)
      end.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
    end
  end
end

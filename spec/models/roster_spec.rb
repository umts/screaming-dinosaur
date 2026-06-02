# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster do
  before { freeze_time }

  describe '#on_call_user' do
    subject(:result) { roster.on_call_user }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }
    let(:assignment) { create :assignment, roster: }

    context 'when there is a current assignment' do
      let(:assignment) { create(:assignment, roster:, user: create(:user)) }

      before do
        allow(roster).to receive(:current_assignment).and_return(assignment)
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

  describe '#switchover_time=' do
    subject(:call) { roster.switchover_time = value }

    let(:roster) { build :roster }

    context 'with a time object' do
      let(:value) { Time.zone.parse('12:30') }

      it 'converts time to minutes' do
        call
        expect(roster.switchover).to eq((12 * 60) + 30)
      end
    end

    context 'when switchover_time is nil' do
      let(:value) { nil }

      it 'set switchover time to nil' do
        call
        expect(roster.switchover).to be_nil
      end
    end

    context 'when switchover_time is string' do
      let(:value) { '12:30' }

      it 'set switchover time to nil' do
        call
        expect(roster.switchover).to eq((12 * 60) + 30)
      end
    end
  end

  describe '#uncovered_datetimes_between' do
    subject(:call) { roster.uncovered_datetimes_between(start_datetime, end_datetime) }

    let(:roster) { create :roster }
    let(:start_datetime) { Time.current }
    let(:end_datetime) { 1.week.from_now }

    before { create :assignment, roster:, start_datetime: 1.day.from_now, end_datetime: 6.days.from_now }

    it 'returns the datetime with no assignments between the given start and end datetime' do
      expect(call).to eq [7.days.from_now]
    end
  end

  describe '#next_rotation_start_date' do
    subject(:result) { roster.next_rotation_start_date }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }

    context 'with existing assignments' do
      before { create :assignment, roster:, end_datetime: 1.week.from_now }

      it 'returns the day after the last assignment ends' do
        expect(result).to eq 8.days.since
      end
    end

    context 'with no existing assignments' do
      it 'returns the upcoming Friday' do
        travel_to Time.zone.parse('Monday, May 8th, 2017')
        expect(result).to eq Time.current.next_occurring(:friday)
      end
    end

    context 'with multiple assignments' do
      before do
        create :assignment, roster:, end_datetime: 2.days.from_now
        create :assignment, roster:, end_datetime: 10.days.from_now
      end

      it 'returns the day after the last assignment ends with latest end date' do
        expect(result).to eq 11.days.from_now
      end
    end
  end

  describe '#save' do
    subject(:call) { roster.save }

    context 'when the roster is a new roster' do
      let(:roster) { build :roster }

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end

    context 'when there are admins in the roster and the fallback_user_id changes' do
      let(:roster) { create :roster }

      before do
        create(:membership, roster:, admin: true)
        roster.fallback_user = create(:user)
      end

      it 'sends a notification with the correct roster' do
        expect { call }.to have_enqueued_email(RosterMailer, :fallback_number_changed)
          .with(params: { roster: roster }, args: [])
      end
    end

    context 'when the fallback_user_id does not change' do
      let(:roster) { create :roster }

      before { roster.name = 'New name' }

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end

    context 'when there are no admins in the roster and the fallback_user_id changes' do
      let(:roster) { create :roster }

      before { roster.fallback_user = create(:user) }

      it 'does not send a notification' do
        expect { call }.not_to have_enqueued_email(RosterMailer, :fallback_number_changed)
      end
    end
  end
end

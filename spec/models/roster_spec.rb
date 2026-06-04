# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster do
  before { freeze_time }

  describe '#on_call_user' do
    subject(:call) { roster.on_call_user }

    let(:roster) { create :roster, fallback_user: create(:user), created_at: 1.day.ago }

    before { freeze_time }

    context 'when there is no current assignment' do
      it 'returns the fallback user' do
        expect(call).to eq(roster.fallback_user)
      end
    end

    context 'when there is a current assignment with no user' do
      before { create :assignment, roster:, user: nil, end_datetime: 1.day.from_now }

      it 'returns the fallback user' do
        expect(call).to eq(roster.fallback_user)
      end
    end

    context 'when there is a current assignment with a user' do
      let!(:assignment) do
        create :assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: 1.day.from_now
      end

      it 'returns the user' do
        expect(call).to eq(assignment.user)
      end
    end
  end

  describe '#uncovered_periods_between' do
    subject(:call) { roster.uncovered_periods_between(start_time, end_time) }

    let(:roster) { create :roster, created_at: 3.weeks.ago }
    let(:start_time) { Time.zone.local(2026, 6, 1, 0, 0, 0) }
    let(:end_time) { Time.zone.local(2026, 6, 15, 0, 0, 0) }

    context 'when the roster has no assignments' do
      it 'returns one period spanning the full input range' do
        expect(call).to eq [{ start_datetime: start_time, end_datetime: end_time }]
      end
    end

    context 'when the last assignment ends after the input range' do
      before do
        create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 25, 0, 0, 0)
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 6, 20, 0, 0, 0)
      end

      it 'returns an empty array' do
        expect(call).to eq []
      end
    end

    context 'with a user_id-nil assignment fully inside the range' do
      let(:gap_start) { Time.zone.local(2026, 6, 5, 0, 0, 0) }
      let(:gap_end) { Time.zone.local(2026, 6, 7, 0, 0, 0) }

      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: gap_start
        create :assignment, roster:, user: nil, end_datetime: gap_end
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 6, 20, 0, 0, 0)
      end

      it 'returns one period matching the unassigned assignment' do
        expect(call).to eq [{ start_datetime: gap_start, end_datetime: gap_end }]
      end
    end

    context 'when the last assignment ends before the input range end' do
      let(:last_end) { Time.zone.local(2026, 6, 10, 0, 0, 0) }

      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: last_end
      end

      it 'returns a tail period from the last end_datetime to end_time' do
        expect(call).to eq [{ start_datetime: last_end, end_datetime: end_time }]
      end
    end

    context 'with a user_id-nil assignment entirely before the input range' do
      before do
        create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 5, 20, 0, 0, 0)
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 6, 30, 0, 0, 0)
      end

      it 'does not include the pre-range assignment' do
        expect(call).to eq []
      end
    end

    context 'with a user_id-nil assignment entirely after the input range' do
      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 6, 20, 0, 0, 0)
        create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 6, 25, 0, 0, 0)
      end

      it 'does not include the post-range assignment' do
        expect(call).to eq []
      end
    end

    context 'with both a mid-range gap and a trailing tail' do
      let(:gap_start) { Time.zone.local(2026, 6, 5, 0, 0, 0) }
      let(:gap_end) { Time.zone.local(2026, 6, 7, 0, 0, 0) }
      let(:last_end) { Time.zone.local(2026, 6, 10, 0, 0, 0) }

      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: gap_start
        create :assignment, roster:, user: nil, end_datetime: gap_end
        create :assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: last_end
      end

      it 'returns both periods' do
        expect(call).to contain_exactly(
          { start_datetime: gap_start, end_datetime: gap_end },
          { start_datetime: last_end, end_datetime: end_time }
        )
      end
    end

    context 'when the last assignment ends exactly at the input range end' do
      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]), end_datetime: end_time
      end

      it 'does not return a zero-length tail' do
        expect(call).to eq []
      end
    end

    context 'with a user_id-nil assignment that starts before the input range' do
      let(:gap_end) { Time.zone.local(2026, 6, 5, 0, 0, 0) }

      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 5, 25, 0, 0, 0)
        create :assignment, roster:, user: nil, end_datetime: gap_end
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 6, 20, 0, 0, 0)
      end

      it 'clips the reported period to start at the input range start' do
        expect(call).to eq [{ start_datetime: start_time, end_datetime: gap_end }]
      end
    end

    context 'with a user_id-nil assignment that ends after the input range' do
      let(:gap_start) { Time.zone.local(2026, 6, 10, 0, 0, 0) }

      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: gap_start
        create :assignment, roster:, user: nil, end_datetime: Time.zone.local(2026, 6, 20, 0, 0, 0)
      end

      it 'clips the reported period to end at the input range end' do
        expect(call).to eq [{ start_datetime: gap_start, end_datetime: end_time }]
      end
    end

    context 'when the last assignment ended before the input range began' do
      before do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            end_datetime: Time.zone.local(2026, 5, 20, 0, 0, 0)
      end

      it 'clips the tail to start at the input range start' do
        expect(call).to eq [{ start_datetime: start_time, end_datetime: end_time }]
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

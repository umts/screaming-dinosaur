# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assignment do
  include ActiveSupport::Testing::TimeHelpers

  describe 'associations' do
    it { is_expected.to belong_to(:roster) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'validations' do
    subject { build :assignment }

    it { is_expected.to validate_presence_of(:end_datetime) }
    it { is_expected.to validate_uniqueness_of(:end_datetime).scoped_to(:roster_id) }
  end

  describe '#previous' do
    subject(:call) { assignment.previous }

    let(:roster) { create :roster }
    let(:assignment) { build_stubbed(:assignment, roster:) }

    before do
      create(:assignment, roster:, end_datetime: assignment.end_datetime + 10.minutes)
      create(:assignment, roster:, end_datetime: assignment.end_datetime + 5.minutes)
      create :assignment, end_datetime: assignment.end_datetime - 5.minutes
    end

    context 'when there are no other assignments that have the same roster and an earlier end datetime' do
      it { is_expected.to be_nil }
    end

    context 'when there are other assignments that have the same roster and an earlier end datetime' do
      let!(:target) { create(:assignment, roster:, end_datetime: assignment.end_datetime - 5.minutes) }

      before { create(:assignment, roster:, end_datetime: assignment.end_datetime - 10.minutes) }

      it 'returns the one with the latest end datetime' do
        expect(call).to eq(target)
      end
    end
  end

  describe '#next' do
    subject(:call) { assignment.next }

    let(:roster) { create :roster }
    let(:assignment) { build_stubbed(:assignment, roster:) }

    before do
      create :assignment, end_datetime: assignment.end_datetime + 5.minutes
      create(:assignment, roster:, end_datetime: assignment.end_datetime - 5.minutes)
      create(:assignment, roster:, end_datetime: assignment.end_datetime - 10.minutes)
    end

    context 'when there are no other assignments that have the same roster and a later end datetime' do
      it { is_expected.to be_nil }
    end

    context 'when there are other assignments that have the same roster and a later end datetime' do
      let!(:target) { create(:assignment, roster:, end_datetime: assignment.end_datetime + 5.minutes) }

      before { create(:assignment, roster:, end_datetime: assignment.end_datetime + 10.minutes) }

      it 'returns the one with the earliest end datetime' do
        expect(call).to eq(target)
      end
    end
  end

  describe '#start_datetime' do
    subject(:call) { assignment.start_datetime }

    context 'when the attribute has been previously set' do
      let(:assignment) { build_stubbed :assignment, start_datetime: value }
      let(:value) { Time.current }

      it 'returns the previously set value' do
        expect(call).to eq(value)
      end
    end

    context 'when the assignment has a predecessor' do
      let(:roster) { create :roster }
      let(:assignment) { build_stubbed(:assignment, roster:) }
      let!(:predecessor) { create(:assignment, roster:, end_datetime: assignment.end_datetime - 5.minutes) }

      before do
        create(:assignment, roster:, end_datetime: assignment.end_datetime + 10.minutes)
        create(:assignment, roster:, end_datetime: assignment.end_datetime + 5.minutes)
        create(:assignment, roster:, end_datetime: assignment.end_datetime - 10.minutes)
        create :assignment, end_datetime: assignment.end_datetime - 5.minutes
      end

      it "returns the predecessor's end datetime" do
        expect(call).to eq(predecessor.end_datetime)
      end
    end

    context 'when the assignment has no predecessor' do
      let(:roster) { create :roster }
      let(:assignment) { build_stubbed(:assignment, roster:) }

      it "returns the roster's create datetime" do
        expect(call).to eq(roster.created_at)
      end
    end
  end

  describe '.with_start_datetimes' do
    subject(:call) { described_class.with_start_datetimes }

    let(:time) { Time.current }
    let(:rosters) { create_list :roster, 2 }
    let!(:roster_one_assignments) do
      [1.minute.after(time), 1.minute.before(time), 3.minutes.before(time)].map do |end_datetime|
        create(:assignment, roster: rosters.first, end_datetime:)
      end.sort_by(&:end_datetime)
    end
    let!(:roster_two_assignments) do
      [2.minutes.after(time), time, 2.minutes.before(time)].map do |end_datetime|
        create(:assignment, roster: rosters.second, end_datetime:)
      end.sort_by(&:end_datetime)
    end

    it 'returns a relation' do
      expect(call).to be_a(ActiveRecord::Relation)
    end

    it 'preloads start datetimes at the database level and writes them to attributes' do
      expect(call.collect(&:attributes)).to contain_exactly(
        a_hash_including('id' => roster_one_assignments.first.id,
                         'start_datetime' => nil),
        a_hash_including('id' => roster_one_assignments.second.id,
                         'start_datetime' => roster_one_assignments.first.end_datetime),
        a_hash_including('id' => roster_one_assignments.third.id,
                         'start_datetime' => roster_one_assignments.second.end_datetime),
        a_hash_including('id' => roster_two_assignments.first.id,
                         'start_datetime' => nil),
        a_hash_including('id' => roster_two_assignments.second.id,
                         'start_datetime' => roster_two_assignments.first.end_datetime),
        a_hash_including('id' => roster_two_assignments.third.id,
                         'start_datetime' => roster_two_assignments.second.end_datetime)
      )
    end
  end
end

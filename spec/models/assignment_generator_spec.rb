# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGenerator do
  let(:assignment_generator) do
    described_class.new(
      roster_id: roster.id,
      user_id: user.id,
      start_date: start_date,
      end_date: end_date,
      end_time: end_time,
      weekdays: weekdays
    )
  end

  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster] }

  describe '#perform' do
    subject(:submit) { assignment_generator.perform }

    context 'when valid attributes are provided' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:end_time) { Time.zone.parse('05:00') }
      let(:weekdays) { %w[Tuesday Thursday Friday] }

      it 'creates assignments on selected weekdays' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.strftime('%A')).to be_in(%w[Tuesday Thursday Friday])
        end
      end

      it 'sets correct end_time for all the assignments' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.strftime('%H:%M')).to eq '05:00'
        end
      end

      it 'creates assignments only within the given date range' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.to_date).to be_between(start_date, end_date).inclusive
        end
      end

      it 'creates new assignments' do
        count = (start_date..end_date).count { |date| weekdays.include?(date.strftime('%A')) }
        expect { submit }.to change(Assignment, :count).by(count)
      end
    end

    context 'when invalid attributes are used' do
      let(:start_date) { Date.current }
      let(:end_date) { nil }
      let(:end_time) { Time.zone.parse('05:00') }
      let(:weekdays) { [] }

      it 'returns false' do
        expect(submit).to be(false)
      end
    end
  end
end

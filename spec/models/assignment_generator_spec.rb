# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGenerator do
  let(:roster) { create(:roster) }
  let(:user) { create(:user, rosters: [roster]) }

  let(:assignment_generator) do
    described_class.new(roster_id: roster.id, user_id: user.id, **attributes)
  end

  describe '#perform' do
    subject(:submit) { assignment_generator.perform }

    context 'when valid attributes are provided' do
      let(:attributes) do
        { start_date: Date.current, end_date: Date.current + 14.days,
          end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
      end

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
        start_date, end_date = attributes.values_at(:start_date, :end_date)
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.to_date).to be_between(start_date, end_date).inclusive
        end
      end

      it 'creates new assignments' do
        start_date, end_date, weekdays = attributes.values_at(:start_date, :end_date, :weekdays)
        count = (start_date..end_date).count { |date| weekdays.include?(date.strftime('%A')) }
        expect { submit }.to change(Assignment, :count).by(count)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when assignments generated without a group' do
      let(:attributes) do
        { start_date: Date.current, end_date: Date.current + 14.days,
          end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
      end

      it 'does not create any assignment groups' do
        expect { submit }.not_to change(AssignmentGroup, :count)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when assignments generated with group' do
      let(:attributes) do
        { start_date: Date.current, end_date: Date.current + 14.days,
          end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], group: 'Morning Shift' }
      end

      let(:weekly_assignments) do
        submit
        roster.assignments.group_by do |assignment|
          assignment.end_datetime.to_date.beginning_of_week(:monday)
        end
      end

      it 'creates one assignment group per week' do
        expect { submit }.to change(AssignmentGroup, :count)
      end

      it 'assigns every assignment to an assignment group' do
        submit
        expect(roster.assignments.pluck(:assignment_group_id)).to all(be_present)
      end

      it 'creates assignment groups with the given name' do
        submit
        expect(AssignmentGroup.pluck(:name)).to all(eq('Morning Shift'))
      end

      it 'uses one assignment group per week' do
        weekly_assignments.each_value do |assignments|
          expect(assignments.map(&:assignment_group_id).uniq.size).to eq(1)
        end
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when invalid attributes are used' do
      let(:attributes) do
        { start_date: Date.current, end_date: nil, end_time: Time.zone.parse('05:00'), weekdays: [] }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end

    context 'when invalid assignment attributes are used' do
      let(:attributes) do
        { start_date: Date.current, end_date: Date.current,
          end_time: Time.zone.parse('05:00'), weekdays: Date::DAYNAMES }
      end

      before do
        start = attributes[:start_date]
        create(:assignment, roster:,
                            end_datetime: Time.zone.local(start.year, start.month, start.day, 5, 0))
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end
  end
end

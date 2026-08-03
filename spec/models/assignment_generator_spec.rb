# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGenerator do
  let(:roster) { create(:roster) }
  let(:user) { create(:user, rosters: [roster]) }

  let(:assignment_generator) do
    described_class.new(roster_id: roster.id, user_id: user.id, definitions_attributes: definitions_attributes)
  end

  describe '#perform' do
    subject(:submit) { assignment_generator.perform }

    context 'when valid attributes are provided' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current + 14.days,
                   end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
        }
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
        start_date, end_date = definitions_attributes['0'].values_at(:start_date, :end_date)
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.to_date).to be_between(start_date, end_date).inclusive
        end
      end

      it 'creates new assignments' do
        start_date, end_date, weekdays = definitions_attributes['0'].values_at(:start_date, :end_date, :weekdays)
        count = (start_date..end_date).count { |date| weekdays.include?(date.strftime('%A')) }
        expect { submit }.to change(Assignment, :count).by(count)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when assignments generated without a group' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current + 14.days,
                   end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
        }
      end

      it 'does not create any assignment groups' do
        expect { submit }.not_to change(AssignmentGroup, :count)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when assignments generated with group' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current + 14.days,
                   end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], group: 'Morning Shift' }
        }
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

    context 'when multiple definitions are provided' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current + 6.days,
                   end_time: Time.zone.parse('05:00'), weekdays: %w[Monday Tuesday], group: 'Morning Shift' },
          '1' => { start_date: Date.current + 7.days, end_date: Date.current + 13.days,
                   end_time: Time.zone.parse('06:00'), weekdays: %w[Wednesday Thursday] }
        }
      end

      def expected_assignment_count(definition)
        (definition[:start_date]..definition[:end_date]).count do |date|
          definition[:weekdays].include?(date.strftime('%A'))
        end
      end

      def assignments_for(definition)
        roster.assignments.select do |assignment|
          assignment.end_datetime.to_date.between?(definition[:start_date], definition[:end_date])
        end
      end

      def weekly_assignments(assignments)
        assignments.group_by do |assignment|
          assignment.end_datetime.to_date.beginning_of_week(:monday)
        end
      end

      it 'creates the expected number of assignments for the first definition' do
        submit
        assignments = assignments_for(definitions_attributes['0'])
        expect(assignments.size).to eq(expected_assignment_count(definitions_attributes['0']))
      end

      it 'uses the correct weekdays for the first definition' do
        submit
        assignments = assignments_for(definitions_attributes['0'])
        expect(assignments.map do |a|
          a.end_datetime.strftime('%A')
        end.uniq.sort).to eq(definitions_attributes['0'][:weekdays].sort)
      end

      it 'uses the correct end time for the first definition' do
        submit
        assignments = assignments_for(definitions_attributes['0'])
        expect(assignments.map { |a| a.end_datetime.strftime('%H:%M') }.uniq).to eq(['05:00'])
      end

      it 'creates assignment groups only for the first definition with a group name' do
        submit
        assignments = assignments_for(definitions_attributes['0'])
        group_ids = assignments.map(&:assignment_group_id)
        expect(AssignmentGroup.where(id: group_ids).pluck(:name)).to all(eq('Morning Shift'))
      end

      it 'uses one assignment group per week' do
        submit
        assignments = assignments_for(definitions_attributes['0'])
        weekly_assignments(assignments).each_value do |week_assignments|
          expect(week_assignments.map(&:assignment_group_id).uniq.size).to eq(1)
        end
      end

      it 'creates the expected number of assignments for the second definition' do
        submit
        assignments = assignments_for(definitions_attributes['1'])
        expect(assignments.size).to eq(expected_assignment_count(definitions_attributes['1']))
      end

      it 'uses the correct weekdays for the second definition' do
        submit
        assignments = assignments_for(definitions_attributes['1'])
        expect(assignments.map do |a|
          a.end_datetime.strftime('%A')
        end.uniq.sort).to eq(definitions_attributes['1'][:weekdays].sort)
      end

      it 'uses the correct end time for the second definition' do
        submit
        assignments = assignments_for(definitions_attributes['1'])
        expect(assignments.map { |a| a.end_datetime.strftime('%H:%M') }.uniq).to eq(['06:00'])
      end

      it 'does not create assignment groups' do
        submit
        assignments = assignments_for(definitions_attributes['1'])
        expect(assignments.map(&:assignment_group_id)).to all(be_nil)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when invalid attributes are used' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: nil, end_time: Time.zone.parse('05:00'), weekdays: [] }
        }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end

    context 'when one of multiple definitions is invalid' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current + 6.days,
                   end_time: Time.zone.parse('05:00'), weekdays: %w[Monday] },
          '1' => { start_date: Date.current, end_date: nil,
                   end_time: Time.zone.parse('05:00'), weekdays: [] }
        }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end

      it 'does not create any assignments from the valid definition either' do
        expect { submit }.not_to change(Assignment, :count)
      end
    end

    context 'when invalid assignment attributes are used' do
      let(:definitions_attributes) do
        {
          '0' => { start_date: Date.current, end_date: Date.current,
                   end_time: Time.zone.parse('05:00'), weekdays: Date::DAYNAMES }
        }
      end

      before do
        start = definitions_attributes['0'][:start_date]
        create(:assignment, roster:,
                            end_datetime: Time.zone.local(start.year, start.month, start.day, 5, 0))
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end
  end
end

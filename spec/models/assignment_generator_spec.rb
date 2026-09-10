# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGenerator do
  let(:roster) { create(:roster) }
  let(:assignment_generator) do
    described_class.new(roster_id: roster.id, start_date:, end_date:, definitions_attributes:)
  end

  describe '#perform' do
    subject(:submit) do
      assignment_generator.perform
    end

    context 'when valid attributes are provided' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
        }
      end

      it 'creates assignments on selected weekdays' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.strftime('%A')).to be_in(definitions_attributes['0'][:weekdays])
        end
      end

      it 'sets correct end time for all the assignments' do
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
        expect { submit }.to change(Assignment, :count).by(
          (start_date..end_date).count do |date|
            definitions_attributes['0'][:weekdays].include?(date.strftime('%A'))
          end
        )
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when assignments generated without a group' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
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
      let(:start_date) { Date.current.beginning_of_week(:monday) }
      let(:end_date) { start_date + 13.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], group: 'Morning Shift' }
        }
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

      it 'distributes assignments across all groups created' do
        submit
        expect(AssignmentGroup.all.map { |group| group.assignments.count }).to all(eq(3))
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when multiple definitions are provided' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Monday Tuesday], group: 'Morning Shift' },
          '1' => { end_time: Time.zone.parse('06:00'), weekdays: %w[Wednesday Thursday] }
        }
      end

      def expected_assignment_count(definition)
        (start_date..end_date).count do |date|
          definition[:weekdays].include? date.strftime('%A')
        end
      end

      def assignments_for(definition)
        roster.assignments.select do |assignment|
          definition[:weekdays].include? assignment.end_datetime.strftime('%A')
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

      it 'does not create assignment groups for the second definition' do
        submit
        assignments = assignments_for(definitions_attributes['1'])
        expect(assignments.map(&:assignment_group_id)).to all(be_nil)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when invalid attributes are used' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: [] }
        }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end

    context 'when one of multiple definitions is invalid' do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 14.days }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Monday] },
          '1' => { end_time: Time.zone.parse('05:00'), weekdays: [] }
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
      let(:start_date) { Date.current }
      let(:end_date) { Date.current }
      let(:definitions_attributes) do
        {
          '0' => { end_time: Time.zone.parse('05:00'), weekdays: Date::DAYNAMES }
        }
      end

      before do
        create(:assignment, roster:,
                            end_datetime: Time.zone.local(start_date.year, start_date.month, start_date.day, 5, 0))
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end
  end
end

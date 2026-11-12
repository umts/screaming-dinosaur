# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGenerator do
  let(:roster) { create(:roster) }
  let(:assignment_generator) do
    described_class.new(attributes.merge({ roster_id: roster.id }))
  end

  describe '#perform' do
    subject(:submit) do
      assignment_generator.perform
    end

    context 'when valid attributes are provided' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], credits: 2 }
          }
        }
      end

      it 'creates assignments on selected weekdays' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.end_datetime.strftime('%A')).to be_in(attributes[:definitions_attributes]['0'][:weekdays])
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
          expect(assignment.end_datetime.to_date)
            .to be_between(attributes[:start_date], attributes[:end_date]).inclusive
        end
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(
          (attributes[:start_date]..attributes[:end_date]).count do |date|
            attributes[:definitions_attributes]['0'][:weekdays].include?(date.strftime('%A'))
          end
        )
      end

      it 'sets the right credit count for each assignment' do
        submit
        roster.assignments.each do |assignment|
          expect(assignment.credits).to eq attributes[:definitions_attributes]['0'][:credits]
        end
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when the assignments run overnight' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], overnight: true }
          }
        }
      end

      it 'creates assignments on selected weekdays' do
        submit
        roster.assignments.each do |assignment|
          original_end_datetime = assignment.end_datetime - 1.day
          expect(original_end_datetime.strftime('%A')).to be_in(attributes[:definitions_attributes]['0'][:weekdays])
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
          original_end_datetime = assignment.end_datetime - 1.day
          expect(original_end_datetime.to_date)
            .to be_between(attributes[:start_date], attributes[:end_date] + 1.day).inclusive
        end
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(
          (attributes[:start_date]..attributes[:end_date]).count do |date|
            attributes[:definitions_attributes]['0'][:weekdays].include?(date.strftime('%A'))
          end
        )
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when the assignments are auto assigned' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 6.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Monday Tuesday Wednesday Thursday Friday] }
          },
          auto_assign: true
        }
      end

      before do
        create_list(:membership, 5, roster:)
        create(:assignment, end_datetime: Date.current - 1.day, user: User.order(:last_name).third, roster:)
      end

      it 'creates assignments on selected weekdays' do
        submit
        roster.assignments.drop(1).each do |assignment|
          expect(assignment.end_datetime.strftime('%A')).to be_in(attributes[:definitions_attributes]['0'][:weekdays])
        end
      end

      it 'sets correct end time for all the assignments' do
        submit
        roster.assignments.drop(1).each do |assignment|
          expect(assignment.end_datetime.strftime('%H:%M')).to eq '05:00'
        end
      end

      it 'creates assignments only within the given date range' do
        submit
        roster.assignments.drop(1).each do |assignment|
          expect(assignment.end_datetime.to_date).to(
            be_between(attributes[:start_date], attributes[:end_date]).inclusive
          )
        end
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(
          (attributes[:start_date]..attributes[:end_date]).count do |date|
            attributes[:definitions_attributes]['0'][:weekdays].include?(date.strftime('%A'))
          end
        )
      end

      it 'assigns users in alphabetical order, starting after the last assigned user' do
        submit
        last_names = User.order(:last_name).pluck(:last_name).rotate(3)
        expect(roster.assignments.order(:end_datetime).drop(1)
               .map { |assignment| assignment.user.last_name }).to eql last_names
      end

      it 'returns true' do
        expect(submit).to be true
      end
    end

    context 'when assignments generated without a group' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday] }
          }
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
      let(:attributes) do
        {
          start_date: Date.current.beginning_of_week(:monday),
          end_date: Date.current.beginning_of_week(:monday) + 13.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Tuesday Thursday Friday], group: 'Morning Shift' }
          }
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
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Monday Tuesday], group: 'Morning Shift' },
            '1' => { end_time: Time.zone.parse('06:00'), weekdays: %w[Wednesday Thursday], credits: 10 }
          }
        }
      end

      def expected_assignment_count(definition)
        (attributes[:start_date]..attributes[:end_date]).count do |date|
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
        assignments = assignments_for(attributes[:definitions_attributes]['0'])
        expect(assignments.size).to eq(expected_assignment_count(attributes[:definitions_attributes]['0']))
      end

      it 'uses the correct weekdays for the first definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['0'])
        expect(assignments.map do |a|
          a.end_datetime.strftime('%A')
        end.uniq.sort).to eq(attributes[:definitions_attributes]['0'][:weekdays].sort)
      end

      it 'uses the correct end time for the first definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['0'])
        expect(assignments.map { |a| a.end_datetime.strftime('%H:%M') }.uniq).to eq(['05:00'])
      end

      it 'creates assignment groups only for the first definition with a group name' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['0'])
        group_ids = assignments.map(&:assignment_group_id)
        expect(AssignmentGroup.where(id: group_ids).pluck(:name)).to all(eq('Morning Shift'))
      end

      it 'uses one assignment group per week' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['0'])
        weekly_assignments(assignments).each_value do |week_assignments|
          expect(week_assignments.map(&:assignment_group_id).uniq.size).to eq(1)
        end
      end

      it 'creates the expected number of assignments for the second definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['1'])
        expect(assignments.size).to eq(expected_assignment_count(attributes[:definitions_attributes]['1']))
      end

      it 'uses the correct weekdays for the second definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['1'])
        expect(assignments.map do |a|
          a.end_datetime.strftime('%A')
        end.uniq.sort).to eq(attributes[:definitions_attributes]['1'][:weekdays].sort)
      end

      it 'uses the correct credit count for the second definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['1'])
        expect(assignments.map(&:credits).uniq).to eq([10])
      end

      it 'uses the correct end time for the second definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['1'])
        expect(assignments.map { |a| a.end_datetime.strftime('%H:%M') }.uniq).to eq(['06:00'])
      end

      it 'does not create assignment groups for the second definition' do
        submit
        assignments = assignments_for(attributes[:definitions_attributes]['1'])
        expect(assignments.map(&:assignment_group_id)).to all(be_nil)
      end

      it 'returns true' do
        expect(submit).to be(true)
      end
    end

    context 'when invalid attributes are used' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[] }
          }
        }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end

    context 'when one of multiple definitions is invalid' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current + 14.days,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: %w[Monday] },
            '1' => { end_time: Time.zone.parse('05:00'), weekdays: [] }
          }
        }
      end

      it 'returns false' do
        expect(submit).to be(false)
      end

      it 'does not create any assignments from the valid definition either' do
        expect { submit }.not_to change(Assignment, :count)
      end
    end

    context 'when an invalid date range is used' do
      let(:attributes) do
        {
          start_date: Date.current,
          end_date: Date.current,
          definitions_attributes: {
            '0' => { end_time: Time.zone.parse('05:00'), weekdays: Date::DAYNAMES }
          }
        }
      end

      before do
        create(
          :assignment,
          roster:,
          end_datetime: Time.zone.local(
            attributes[:start_date].year,
            attributes[:start_date].month,
            attributes[:start_date].day,
            5, 0
          )
        )
      end

      it 'returns false' do
        expect(submit).to be(false)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentsMailer do
  describe 'changed_assignment' do
    subject :output do
      described_class.changed_assignment assignment.roster, assignment.start_datetime,
                                         assignment.end_datetime, recipient, changer
    end

    let(:roster) { create(:roster) }
    let :assignment do
      create(:assignment, roster:,
                          start_datetime: 1.day.from_now, end_datetime: 7.days.from_now)
    end
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }

    it 'emails to the recipient' do
      expect(output.to).to eql Array(recipient.email)
    end

    it 'has a subject mentioning a change' do
      expect(output.subject).to start_with 'Change'
    end

    it 'has a subject mentioning the name of the roster' do
      expect(output.subject).to include roster.name
    end

    it 'includes the first name of the recipient' do
      expect(output.body.encoded).to include recipient.first_name
    end

    it 'includes the full name of the changer' do
      expect(output.body.encoded).to include changer.full_name
    end

    it 'includes the assignment start datetime' do
      expect(output.body.encoded).to include assignment.start_datetime.strftime('%A, %B %e at %-l:%M %P')
    end

    it 'includes the assignment end datetime' do
      expect(output.body.encoded).to include assignment.end_datetime.strftime('%A, %B %e at %-l:%M %P')
    end
  end

  describe 'deleted_assignment' do
    subject :output do
      described_class.deleted_assignment assignment.roster, assignment.start_datetime,
                                         assignment.end_datetime, recipient, changer
    end

    let(:roster) { create(:roster) }
    let :assignment do
      create(:assignment, roster:,
                          start_datetime: 2.days.from_now, end_datetime: 7.days.from_now)
    end
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }

    it 'emails to the recipient' do
      expect(output.to).to eql Array(recipient.email)
    end

    it 'has a subject mentioning a cancellation' do
      expect(output.subject).to start_with 'Cancellation'
    end

    it 'has a subject mentioning the name of the roster' do
      expect(output.subject).to include roster.name
    end

    it 'includes the first name of the recipient' do
      expect(output.body.encoded).to include recipient.first_name
    end

    it 'includes the full name of the changer' do
      expect(output.body.encoded).to include changer.full_name
    end

    it 'includes the assignment start datetime' do
      expect(output.body.encoded).to include assignment.start_datetime.strftime('%A, %B %e at %-l:%M %P')
    end

    it 'includes the assignment end datetime' do
      expect(output.body.encoded).to include assignment.end_datetime.strftime('%A, %B %e at %-l:%M %P')
    end
  end

  describe 'new_assignment' do
    subject :output do
      described_class.new_assignment assignment.roster, assignment.start_datetime,
                                     assignment.end_datetime, recipient, changer
    end

    let(:roster) { create(:roster) }
    let :assignment do
      create(:assignment, roster:,
                          start_datetime: 1.day.from_now, end_datetime: 7.days.from_now)
    end
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }

    it 'emails to the recipient' do
      expect(output.to).to eql Array(recipient.email)
    end

    it 'has a subject mentioning a new assignment' do
      expect(output.subject).to start_with 'New'
    end

    it 'has a subject mentioning the name of the roster' do
      expect(output.subject).to include roster.name
    end

    it 'includes the first name of the recipient' do
      expect(output.body.encoded).to include recipient.first_name
    end

    it 'includes the full name of the changer' do
      expect(output.body.encoded).to include changer.full_name
    end

    it 'includes the assignment start datetime' do
      expect(output.body.encoded).to include assignment.start_datetime.strftime('%A, %B %e at %-l:%M %P')
    end

    it 'includes the assignment end datetime' do
      expect(output.body.encoded).to include assignment.end_datetime.strftime('%A, %B %e at %-l:%M %P')
    end
  end

  describe 'upcoming_reminder' do
    subject(:output) { described_class.upcoming_reminder recipient, assignments }

    let(:roster) { create(:roster, created_at: 1.week.ago) }
    let(:recipient) { roster_user roster }
    let(:assignment) { create(:assignment, roster:, user: recipient, end_datetime: 2.days.from_now) }
    let(:assignments) { [assignment] }

    it 'emails to the recipient' do
      expect(output.to).to eql Array(recipient.email)
    end

    it 'has a generic subject that does not name any roster' do
      expect(output.subject).not_to include roster.name
    end

    it 'greets the recipient by first name' do
      expect(output.body.encoded).to include recipient.first_name
    end

    it 'includes the assignment start datetime in the named format' do
      expect(output.body.encoded).to include I18n.l(assignment.start_datetime, format: :named)
    end

    it 'includes the assignment end datetime in the named format' do
      expect(output.body.encoded).to include I18n.l(assignment.end_datetime, format: :named)
    end

    it "groups assignments under the roster's name" do
      expect(output.body.encoded).to include roster.name
    end

    context 'when the recipient has assignments across multiple rosters' do
      let(:second_assignment) do
        create(:assignment, roster: create(:roster, created_at: 1.week.ago),
                            user: recipient, end_datetime: 3.days.from_now)
      end
      let(:assignments) { [assignment, second_assignment] }

      it 'includes both roster names in the body' do
        body = output.body.encoded
        expect(body).to include(roster.name).and include(second_assignment.roster.name)
      end
    end
  end
end

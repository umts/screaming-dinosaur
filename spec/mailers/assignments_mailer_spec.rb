# frozen_string_literal: true

RSpec.describe AssignmentsMailer do
  describe 'changed_assignment' do
    subject :output do
      described_class.changed_assignment assignment.roster, assignment.effective_start_datetime,
                                         assignment.effective_end_datetime, recipient, changer
    end

    let(:roster) { create :roster, switchover: 9 * 60 }
    let :assignment do
      create :assignment, roster:,
                          start_date: Date.new(2017, 4, 21), end_date: Date.new(2017, 4, 27)
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

    it 'includes the assignment start date and time' do
      expect(output.body.encoded).to include 'Friday, April 21 at 9:00 am'
    end

    it 'includes the assignment end date and time' do
      expect(output.body.encoded).to include 'Friday, April 28 at 9:00 am'
    end
  end

  describe 'deleted_assignment' do
    subject :output do
      described_class.deleted_assignment assignment.roster, assignment.effective_start_datetime,
                                         assignment.effective_end_datetime, recipient, changer
    end

    let(:roster) { create :roster, switchover: 10 * 60 }
    let :assignment do
      create :assignment, roster:,
                          start_date: Date.new(2017, 4, 21), end_date: Date.new(2017, 4, 27)
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

    it 'includes the assignment start date and time' do
      expect(output.body.encoded).to include 'Friday, April 21 at 10:00 am'
    end

    it 'includes the assignment end date and time' do
      expect(output.body.encoded).to include 'Friday, April 28 at 10:00 am'
    end
  end

  describe 'new_assignment' do
    subject :output do
      described_class.new_assignment assignment.roster, assignment.effective_start_datetime,
                                     assignment.effective_end_datetime, recipient, changer
    end

    let(:roster) { create :roster, switchover: 11 * 60 }
    let :assignment do
      create :assignment, roster:,
                          start_date: Date.new(2017, 4, 21), end_date: Date.new(2017, 4, 27)
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

    it 'includes the assignment start date and time' do
      expect(output.body.encoded).to include 'Friday, April 21 at 11:00 am'
    end

    it 'includes the assignment end date and time' do
      expect(output.body.encoded).to include 'Friday, April 28 at 11:00 am'
    end
  end

  describe 'upcoming_reminder' do
    subject :output do
      described_class.upcoming_reminder assignment.roster, assignment.effective_start_datetime,
                                        assignment.effective_end_datetime, assignment.user
    end

    let(:roster) { create :roster, switchover: 12 * 60 }
    let :assignment do
      create :assignment, roster:,
                          start_date: Date.new(2017, 4, 14), end_date: Date.new(2017, 4, 20)
    end
    let(:user) { assignment.user }

    it 'emails to the user' do
      expect(output.to).to eql Array(user.email)
    end

    it 'has a subject including the name of the roster' do
      expect(output.subject).to include roster.name
    end

    it 'includes the roster name' do
      expect(output.body.encoded).to include roster.name
    end

    it 'includes the assignment start date and time' do
      expect(output.body.encoded).to include 'Friday, April 14 at 12:00 pm'
    end

    it 'includes the assignment end date and time' do
      expect(output.body.encoded).to include 'Friday, April 21 at 12:00 pm'
    end
  end
end

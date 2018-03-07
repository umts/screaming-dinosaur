# frozen_string_literal: true

require 'spec_helper'

describe AssignmentsMailer do
  describe 'changed_assignment' do
    let(:start_date) { Date.parse '2017-04-21' }
    let(:end_date) { Date.parse '2017-04-27' }
    let :assignment do
      create :assignment, start_date: start_date, end_date: end_date
    end
    let(:roster) { assignment.roster }
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }
    before :each do
      expect(CONFIG).to receive(:[])
        .with(:switchover_hour)
        .at_least(:once)
        .and_return 9
    end
    let :output do
      described_class.changed_assignment assignment, recipient, changer
    end
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
    let(:start_date) { Date.parse '2017-04-21' }
    let(:end_date) { Date.parse '2017-04-27' }
    let :assignment do
      create :assignment, start_date: start_date, end_date: end_date
    end
    let(:roster) { assignment.roster }
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }
    before :each do
      expect(CONFIG).to receive(:[])
        .with(:switchover_hour)
        .at_least(:once)
        .and_return 10
    end
    let :output do
      described_class.deleted_assignment assignment, recipient, changer
    end
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
    let(:start_date) { Date.parse '2017-04-21' }
    let(:end_date) { Date.parse '2017-04-27' }
    let :assignment do
      create :assignment, start_date: start_date, end_date: end_date
    end
    let(:roster) { assignment.roster }
    let(:recipient) { roster_user roster }
    let(:changer) { roster_admin roster }
    before :each do
      expect(CONFIG).to receive(:[])
        .with(:switchover_hour)
        .at_least(:once)
        .and_return 11
    end
    let :output do
      described_class.new_assignment assignment, recipient, changer
    end
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
    let(:start_date) { Date.parse('2017-04-14') }
    let(:end_date) { Date.parse('2017-04-20') }
    let :assignment do
      create :assignment, start_date: start_date, end_date: end_date
    end
    let(:roster) { assignment.roster }
    let(:user) { assignment.user }
    before :each do
      expect(CONFIG).to receive(:[])
        .with(:switchover_hour)
        .at_least(:once)
        .and_return 12
    end
    let :output do
      described_class.upcoming_reminder assignment
    end
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

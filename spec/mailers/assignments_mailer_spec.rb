require 'rails_helper'

describe AssignmentsMailer do
  describe 'changed_assignment' do
    # TODO
  end

  describe 'deleted_assignment' do
    # TODO
  end

  describe 'new_assignment' do
    # TODO
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

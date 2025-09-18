# frozen_string_literal: true

RSpec.describe Assignment do
  include ActiveSupport::Testing::TimeHelpers

  describe 'effective time methods' do
    let(:roster) { create :roster, switchover: 14 * 60 }
    let :assignment do
      create :assignment, roster:,
                          start_date: Date.new(2017, 4, 10), end_date: Date.new(2017, 4, 11)
    end

    describe 'effective_start_datetime' do
      it 'returns the start date, at the switchover hour' do
        expect(assignment.effective_start_datetime)
          .to eql Time.zone.local(2017, 4, 10, 14)
      end
    end

    describe 'effective_end_datetime' do
      it 'returns the day after the end date, at the switchover hour' do
        expect(assignment.effective_end_datetime)
          .to eql Time.zone.local(2017, 4, 12, 14)
      end
    end
  end

  describe 'current' do
    subject(:call) { described_class.current }

    let(:roster) { create :roster }
    let! :yesterday do
      date = Date.new(2019, 11, 12)
      create :assignment, start_date: date, end_date: date, roster:
    end
    let! :today do
      date = Date.new(2019, 11, 13)
      create :assignment, start_date: date, end_date: date, roster:
    end
    let :switchover_time do
      Date.new(2019, 11, 13) + roster.switchover.minutes
    end

    context 'when it is before the switchover hour' do
      it "returns yesterday's assignment" do
        travel_to 1.minute.before(switchover_time)
        expect(call).to eq yesterday
      end
    end

    context 'when it is after the switchover hour' do
      it "returns today's assignment" do
        travel_to 1.minute.after(switchover_time)
        expect(call).to eq today
      end
    end

    context 'with assignments in multiple rosters' do
      before do
        travel_to 1.minute.after(switchover_time)
      end

      let! :new_assignment do
        # This new assignment will also belong to a new roster
        create :assignment, start_date: Time.zone.today, end_date: Time.zone.today
      end

      it 'includes assignments in the current roster' do
        expect(roster.assignments.current).to eq today
      end

      it 'includes assignments in the other roster when called on the other roster' do
        expect(new_assignment.roster.assignments.current).to eq new_assignment
      end
    end
  end

  describe 'notify' do
    subject(:submit) { assignment.notify(recipient, of: change_type, by: changer) }

    let(:assignment) { create :assignment }
    let(:recipient) { assignment.user }
    let(:change_type) { :changed_assignment }
    let(:changer) { create :user }

    before do
      %i[changed_assignment new_assignment deleted_assignment].each do |method|
        allow(AssignmentsMailer).to receive(method).and_call_original
      end
    end

    context 'when the changer is the recipient' do
      let(:changer) { recipient }

      it 'does not send an email' do
        submit
        expect(AssignmentsMailer).not_to have_received(:changed_assignment)
      end
    end

    context 'when the changer is not the recipient' do
      context 'when the change type is "create"' do
        let(:change_type) { :new_assignment }

        it 'sends the new_assignment mail' do
          submit
          expect(AssignmentsMailer).to have_received(:new_assignment)
            .with(assignment, recipient, changer)
        end
      end

      context 'when the change type is "destroy"' do
        let(:change_type) { :deleted_assignment }

        it 'sends the deleted_assignment mail' do
          submit
          expect(AssignmentsMailer).to have_received(:deleted_assignment)
            .with(assignment, recipient, changer)
        end
      end

      context 'when the change type is "update"' do
        it 'sends the changed_assignment mail' do
          submit
          expect(AssignmentsMailer).to have_received(:changed_assignment)
            .with(assignment, recipient, changer)
        end
      end
    end

    context 'when the recipient is `:owner`' do
      let(:recipient) { :owner }

      it 'sends to the assignment owner' do
        submit
        expect(AssignmentsMailer).to have_received(:changed_assignment)
          .with(assignment, assignment.user, changer)
      end
    end

    context 'when the recipient is another user' do
      let(:recipient) { create :user }

      it 'sends to the recipient, not the owner' do
        submit
        expect(AssignmentsMailer).to have_received(:changed_assignment)
          .with(assignment, recipient, changer)
      end
    end

    context 'when change notifications are disabled' do
      before { recipient.update change_notifications_enabled: false }

      it 'does not send notifications' do
        submit
        expect(AssignmentsMailer).not_to have_received(:changed_assignment)
      end
    end
  end

  describe 'on' do
    subject(:call) { described_class.on date }

    let(:date) { Date.new(2019, 11, 13) }
    let! :correct_assignment do
      create :assignment, start_date: date, end_date: 6.days.after(date)
    end

    before do
      create :assignment, start_date: 1.week.before(date), end_date: 1.day.before(date)
      create :assignment, start_date: 1.week.after(date), end_date: 13.days.after(date)
    end

    it { is_expected.to eq correct_assignment }
  end

  describe 'overlapping assignment validation' do
    let(:roster) { create :roster }

    before do
      create :assignment, roster:,
                          start_date: Time.zone.today,
                          end_date: 6.days.from_now
    end

    context 'when creating assignments that do not overlap' do
      it 'does not add errors' do
        assignments = [[1.week.ago, Date.yesterday],
                       [1.week.from_now, 2.weeks.from_now]].map do |s, e|
          create :assignment, start_date: s, end_date: e, roster: roster
        end
        expect(assignments).to all(be_valid)
      end
    end

    context 'with an overlapping assignment in the same roster' do
      it 'adds errors' do
        assignment = build :assignment,
                           roster: roster,
                           start_date: Date.yesterday,
                           end_date: Date.tomorrow
        expect(assignment).not_to be_valid
      end
    end
  end

  describe 'upcoming' do
    subject { described_class.upcoming }

    let(:roster) { create :roster }
    let :assignment_today do
      create :assignment, roster:,
                          start_date: Time.zone.today, end_date: 1.week.since.to_date
    end
    let :assignment_tomorrow do
      create :assignment, roster:,
                          start_date: Date.tomorrow, end_date: 1.week.since.to_date
    end

    context 'when it is before the switchover' do
      before do
        travel_to 1.minute.before(roster.switchover_time)
      end

      it { is_expected.to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end

    context 'when it is after the switchover' do
      before do
        travel_to 1.minute.after(roster.switchover_time)
      end

      it { is_expected.not_to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end
  end

  describe 'send_reminders!' do
    subject(:call) { described_class.send_reminders! }

    let!(:assignment_today) { create :assignment, start_date: Time.zone.today }
    let!(:assignment_tomorrow) { create :assignment, start_date: Date.tomorrow }

    before { allow(AssignmentsMailer).to receive(:upcoming_reminder).and_call_original }

    it 'sends reminders about assignments starting tomorrow' do
      call
      expect(AssignmentsMailer).to have_received(:upcoming_reminder).with(assignment_tomorrow)
    end

    it 'does not send reminders about assignments starting today' do
      call
      expect(AssignmentsMailer).not_to have_received(:upcoming_reminder).with(assignment_today)
    end
  end
end

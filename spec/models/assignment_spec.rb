# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Assignment do
  describe 'effective time methods' do
    let :assignment do
      create :assignment, start_date: Date.new(2017, 4, 10),
                          end_date: Date.new(2017, 4, 11)
    end
    before :each do
      expect(CONFIG).to receive(:[]).with(:switchover_hour).and_return 14
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
    before :each do
      @yesterday = create :assignment,
                          start_date: Date.new(2019, 11, 12),
                          end_date: Date.new(2019, 11, 12)
      @today = create :assignment,
                      start_date: Date.new(2019, 11, 13),
                      end_date: Date.new(2019, 11, 13)
      @switchover_time = Date.new(2019, 11, 13) +
                         CONFIG.fetch(:switchover_hour).hours
    end
    let :call do
      Assignment.current
    end
    context 'before switchover hour' do
      it "returns yesterday's assignment" do
        Timecop.freeze(@switchover_time - 1.minute) do
          expect(call).to eql @yesterday
        end
      end
    end
    context 'after switchover hour' do
      it "returns today's assignment" do
        Timecop.freeze(@switchover_time + 1.minute) do
          expect(call).to eql @today
        end
      end
    end
    context 'target assignments are only in the current roster' do
      it 'only looks at assignments in the current roster' do
        Timecop.freeze(@switchover_time + 1.minute) do
          # This new assignment will also belong to a new roster
          new_assignment =  create :assignment,
                                   start_date: Date.today,
                                   end_date: Date.today
          expect(@today.roster.assignments.current).to eql @today
          expect(new_assignment.roster.assignments.current)
            .to eql new_assignment
        end
      end
    end
  end

  describe 'next_rotation_start_date' do
    let(:result) { Assignment.next_rotation_start_date }
    context 'with existing assignments' do
      before :each do
        create :assignment, end_date: 1.week.since.to_date
        create :assignment, end_date: 2.weeks.since.to_date
        create :assignment, end_date: 3.weeks.since.to_date
      end
      it 'returns the day after the last assignment ends' do
        expect(result).to eql 22.days.since.to_date
      end
    end
    context 'with no existing assignments' do
      it 'returns the upcoming Friday' do
        Timecop.freeze Date.parse('Monday, May 8th, 2017') do
          expect(result).to eql Date.parse('Friday, May 12th, 2017')
        end
      end
    end
  end

  describe 'notify' do
    let(:roster) { create :roster }
    let(:owner) { roster_user(roster) }
    let(:assignment) { create :assignment, user: owner, roster: roster }
    let(:submit) { assignment.notify recipient, conditions }
    let(:recipient) { owner }
    let(:conditions) { { of: change_type, by: changer } }
    let(:change_type) { :changed_assignment }
    let(:changer) { create :user }
    context 'changer is recipient' do
      let(:changer) { recipient }
      it 'does not send an email' do
        expect(AssignmentsMailer).not_to receive :changed_assignment
        submit
      end
    end
    context 'changer is not recipient' do
      context 'change type is create' do
        let(:change_type) { :new_assignment }
        it 'sends the new_assignment mail' do
          expect(AssignmentsMailer).to receive(:new_assignment)
            .with(assignment, recipient, changer)
            .and_call_original
          submit
        end
      end
      context 'change type is destroy' do
        let(:change_type) { :deleted_assignment }
        it 'sends the deleted_assignment mail' do
          expect(AssignmentsMailer).to receive(:deleted_assignment)
            .with(assignment, recipient, changer)
            .and_call_original
          submit
        end
      end
      context 'change type is update' do
        it 'sends the changed_assignment mail' do
          expect(AssignmentsMailer).to receive(:changed_assignment)
            .with(assignment, recipient, changer)
            .and_call_original
          submit
        end
      end
    end
    context 'recipient is the symbol owner' do
      let(:recipient) { :owner }
      it 'sends to the assignment owner' do
        expect(AssignmentsMailer).to receive(:changed_assignment)
          .with(assignment, owner, changer)
          .and_call_original
        submit
      end
    end
    context 'recipient other than owner' do
      let(:recipient) { create :user }
      it 'sends to the recipient, not the owner' do
        expect(AssignmentsMailer).to receive(:changed_assignment)
          .with(assignment, recipient, changer)
          .and_call_original
        submit
      end
    end
    context 'change notifications disabled' do
      before(:each) { recipient.update change_notifications_enabled: false }
      it 'does not send notifications' do
        expect(AssignmentsMailer).not_to receive :changed_assignment
        submit
      end
    end
  end

  describe 'on' do
    before :each do
      @date = Date.new(2019, 11, 13)
      create :assignment,
             start_date: 1.week.before(@date).to_date,
             end_date: 1.day.before(@date).to_date
      @correct_assignment = create :assignment,
                                   start_date: @date,
                                   end_date: 6.days.since(@date).to_date
      create :assignment,
             start_date: 1.week.since(@date).to_date,
             end_date: 13.days.since(@date).to_date
    end
    let :call do
      Assignment.on @date
    end
    it 'finds the assignment which covers the given date' do
      expect(call).to eql @correct_assignment
    end
  end

  describe 'overlapping assignment validation' do
    before :each do
      @assignment = create :assignment,
                           start_date: Date.today,
                           end_date: 6.days.since.to_date
    end
    context 'creating assignments that do not overlap' do
      it 'does not add errors' do
        cool_assignment = create :assignment,
                                 start_date: 1.week.ago.to_date,
                                 end_date: Date.yesterday
        another_cool_assignment = create :assignment,
                                         start_date: 1.week.since.to_date,
                                         end_date: 2.weeks.since.to_date
        expect(cool_assignment).to be_valid
        expect(another_cool_assignment).to be_valid
      end
    end
    context 'with an overlapping assignment in the same roster' do
      it 'adds errors' do
        not_cool_assignment = build :assignment,
                                    roster: @assignment.roster,
                                    start_date: Date.yesterday,
                                    end_date: Date.tomorrow
        expect(not_cool_assignment).not_to be_valid
      end
    end
  end

  describe 'upcoming' do
    let(:assignment_today) do
      create :assignment,
             start_date: Date.today,
             end_date: 1.week.since.to_date
    end
    let(:assignment_tomorrow) do
      create :assignment,
             start_date: Date.tomorrow,
             end_date: 1.week.since.to_date
    end

    let(:switchover_time) { Date.today + CONFIG.fetch(:switchover_hour).hours }
    subject { described_class.upcoming }
    context 'before 5pm' do
      around :each do |example|
        Timecop.freeze(switchover_time - 1.minute) { example.run }
      end

      it { is_expected.to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end
    context 'after 5pm' do
      around :each do |example|
        Timecop.freeze(switchover_time + 1.minute) { example.run }
      end

      it { is_expected.not_to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end
  end

  describe 'send_reminders!' do
    let(:assignment_today) { create :assignment, start_date: Date.today }
    let(:assignment_tomorrow) { create :assignment, start_date: Date.tomorrow }
    it 'sends reminders about assignments starting tomorrow' do
      expect(AssignmentsMailer)
        .to receive(:upcoming_reminder)
        .with(assignment_tomorrow)
        .and_call_original
      expect(AssignmentsMailer)
        .not_to receive(:upcoming_reminder)
        .with assignment_today
      Assignment.send_reminders!
    end
  end
end

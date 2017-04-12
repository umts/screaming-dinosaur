require 'rails_helper'

RSpec.describe Assignment do
  describe 'current' do
    before :each do
      @yesterday = create :assignment,
                          start_date: Date.yesterday,
                          end_date: Date.yesterday
      @today = create :assignment,
                      start_date: Date.today,
                      end_date: Date.today
      @switchover_time = Date.today + CONFIG.fetch(:switchover_hour).hours
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
    context 'target assignments are only in the current rotation' do
      it 'only looks at assignments in the current rotation' do
        Timecop.freeze(@switchover_time + 1.minute) do
          # This new assignment will also belong to a new rotation
          new_assignment =  create :assignment,
                                   start_date: Date.today,
                                   end_date: Date.today
          expect(@today.rotation.assignments.current).to eql @today
          expect(new_assignment.rotation.assignments.current)
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

  describe 'on' do
    before :each do
      @date = Date.today
      create :assignment,
             start_date: 1.week.ago.to_date,
             end_date: Date.yesterday
      @correct_assignment = create :assignment,
                                   start_date: Date.today,
                                   end_date: 6.days.since.to_date
      create :assignment,
             start_date: 1.week.since.to_date,
             end_date: 13.days.since.to_date
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
    context 'with an overlapping assignment in the same rotation' do
      it 'adds errors' do
        not_cool_assignment = build :assignment,
               rotation: @assignment.rotation,
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
      before(:each) { Timecop.freeze switchover_time - 1.minute }
      it { is_expected.to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end
    context 'after 5pm' do
      before(:each) { Timecop.freeze switchover_time + 1.minute }
      it { is_expected.not_to include assignment_today }
      it { is_expected.to include assignment_tomorrow }
    end
    after(:each) { Timecop.return }
  end
end

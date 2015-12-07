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
        Timecop.freeze(@switchover_time - 1.minute)
        expect(call).to eql @yesterday
      end
    end
    context 'after switchover hour' do
      it "returns today's assignment" do
        Timecop.freeze(@switchover_time + 1.minute)
        expect(call).to eql @today
      end
    end
  end

  describe 'generate_rotation' do
    before :each do
      @user_1 = create :user
      @user_2 = create :user
      @user_3 = create :user
      start_date = Date.today
      # A day short of four weeks, to test that the end date
      # is a day short as well
      end_date = (4.weeks.since - 2.days).to_date
      @assignments = Assignment.generate_rotation(
        [@user_1.id, @user_2.id, @user_3.id], start_date, end_date
      )
      expect(@assignments.size).to eql 4
    end
    it 'creates the expected assignments (part 1)' do
      assignment = @assignments[0]
      expect(assignment.user).to eql @user_1
      expect(assignment.start_date).to eql Date.today
      expect(assignment.end_date).to eql 6.days.since.to_date
    end
    it 'creates the expected assignments (part 2)' do
      assignment = @assignments[1]
      expect(assignment.user).to eql @user_2
      expect(assignment.start_date).to eql 1.week.since.to_date
      expect(assignment.end_date).to eql 13.days.since.to_date
    end
    it 'creates the expected assignments (part 3)' do
      assignment = @assignments[2]
      expect(assignment.user).to eql @user_3
      expect(assignment.start_date).to eql 2.weeks.since.to_date
      expect(assignment.end_date).to eql 20.days.since.to_date
    end
    # this one is significant because there are more weeks than
    # people - just make sure the modular arithmetic works
    it 'creates the expected assignments (part 4)' do
      assignment = @assignments[3]
      expect(assignment.user).to eql @user_1 # wraps back around
      expect(assignment.start_date).to eql 3.weeks.since.to_date
      expect(assignment.end_date).to eql 26.days.since.to_date
    end
  end

  describe 'next_rotation_start_date' do
    before :each do
      create :assignment, end_date: 1.week.since.to_date
      create :assignment, end_date: 2.weeks.since.to_date
      create :assignment, end_date: 3.weeks.since.to_date
    end
    it 'returns the day after the last assignment ends' do
      result = Assignment.next_rotation_start_date
      expect(result).to eql 22.days.since.to_date
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

  describe 'overlaps_any? (private)' do
    before :each do
      @assignment = create :assignment,
                           start_date: Date.today,
                           end_date: 6.days.since.to_date
    end
    let :call do
      @assignment.send :overlaps_any?
    end
    context 'with no overlapping assignments' do
      it 'does not add errors' do
        create :assignment,
               start_date: 1.week.ago.to_date,
               end_date: Date.yesterday
        create :assignment,
               start_date: 1.week.since.to_date,
               end_date: 2.weeks.since.to_date
        call
        expect(@assignment.errors.messages).to be_empty
      end
    end
    context 'with an overlapping assignment' do
      it 'adds errors' do
        create :assignment,
               start_date: Date.yesterday,
               end_date: Date.tomorrow
        call
        expect(@assignment.errors.messages).not_to be_empty
      end
    end
  end
end

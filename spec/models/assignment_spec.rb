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
        Timecop.freeze(@switchover_time - 1.second)
        expect(call).to eql @yesterday
      end
    end
    context 'after switchover hour' do
      it "returns today's assignment" do
        Timecop.freeze(@switchover_time + 1.second)
        expect(call).to eql @today
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

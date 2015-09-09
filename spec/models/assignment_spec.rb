require 'rails_helper'

RSpec.describe Assignment do
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

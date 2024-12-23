# frozen_string_literal: true

RSpec.describe Roster do
  describe 'generate_assignments' do
    subject :call do
      roster.generate_assignments users.map(&:id), start_date, end_date, users[1].id
    end

    let(:roster) { create :roster }
    let(:users) { Array.new(3) { roster_user(roster) } }

    let(:start_date) { Date.new(2019, 1, 1) }
    # A day short of four weeks, to test that the end date
    # is a day short as well
    let(:end_date) { start_date + 4.weeks - 2.days }

    it 'creates the correct number of assignments' do
      expect(call.size).to be 4
    end

    it 'creates all assignments in the correct roster' do
      expect(call.map(&:roster)).to all(eq(roster))
    end

    context 'with the 1st assignment' do
      let(:assignment) { call[0] }

      # starts in the correct place
      it 'has the correct user' do
        expect(assignment.user).to eq users[1]
      end

      it 'starts on the start date' do
        expect(assignment.start_date).to eq start_date
      end

      it 'ends a week later' do
        expect(assignment.end_date).to eq 6.days.after(start_date)
      end
    end

    context 'with the 2nd assignment' do
      let(:assignment) { call[1] }

      it 'has the correct user' do
        expect(assignment.user).to eq users[2]
      end

      it 'starts 1 week after the start date' do
        expect(assignment.start_date).to eq 1.week.after(start_date)
      end

      it 'ends a week later' do
        expect(assignment.end_date).to eq 13.days.after(start_date)
      end
    end

    context 'with the 3rd assignment' do
      let(:assignment) { call[2] }

      # wraps back around
      it 'has the correct user' do
        expect(assignment.user).to eq users[0]
      end

      it 'starts 2 weeks after the start date' do
        expect(assignment.start_date).to eq 2.weeks.after(start_date)
      end

      it 'ends a week later' do
        expect(assignment.end_date).to eq 20.days.after(start_date)
      end
    end

    # this one is significant because there are more weeks than
    # people - just make sure the modular arithmetic works
    context 'with the 4th assignment' do
      let(:assignment) { call[3] }

      it 'has the correct user' do
        expect(assignment.user).to eq users[1]
      end

      it 'starts 3 weeks after the start date' do
        expect(assignment.start_date).to eq 3.weeks.after(start_date)
      end

      it 'ends on the end date' do
        expect(assignment.end_date).to eq end_date
      end
    end
  end

  describe 'next_rotation_start_date' do
    subject(:result) { roster.next_rotation_start_date }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }

    context 'with existing assignments' do
      before do
        create :assignment, roster:, end_date: 1.weeks.from_now 
      end

      it 'returns the day after the last assignment ends' do
        expect(result).to eql 8.days.since.to_date
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

  describe 'on_call_user' do
    subject(:result) { roster.on_call_user }

    let(:roster) { create :roster, fallback_user: }
    let(:fallback_user) { create :user }
    let(:assignment) { create :assignment, roster: }

    context 'when there is a current assignment' do
      before do
        assignments = roster.assignments
        allow(roster).to receive(:assignments).and_return(assignments)
        allow(assignments).to receive(:current).and_return(assignment)
      end

      it 'returns the user of the current assignment' do
        expect(result).to eql assignment.user
      end
    end

    context "when there isn't a current assignment" do
      it 'returns the fallback user' do
        expect(result).to eql fallback_user
      end
    end
  end

  describe 'user_options' do
    let(:roster) { create :roster }
    let!(:admins) { [roster_admin(roster)] }
    let!(:non_admins) { [roster_user(roster)] }
    let(:call) { roster.user_options }

    it 'has admins in the "Admins"' do
      expect(call.fetch('Admins'))
        .to match_array(admins.map { |a| [a.full_name, a.id] })
    end

    it 'has non-admins in the "Non-Admins"' do
      expect(call.fetch('Non-Admins'))
        .to match_array(non_admins.map { |na| [na.full_name, na.id] })
    end
  end

  describe '#uncovered_dates_between' do
    subject(:call) { roster.uncovered_dates_between(start_date, end_date) }

    let(:roster) { create :roster }
    let(:start_date) { Time.zone.today }
    let(:end_date) { 1.week.from_now }

    before { create :assignment, roster:, start_date: 1.day.from_now, end_date: 6.days.from_now }

    it 'returns the dates with no assignments between the given start and end date' do
      expect(call).to eq [Time.zone.today.to_date, 7.days.from_now.to_date]
    end
  end

  describe '#switchover_time' do
    subject(:call) { roster.switchover_time }

    context 'with a blank switchover' do
      let(:roster) { build :roster, switchover: nil }

      it { is_expected.to be_nil }
    end

    context 'with a switchover' do
      let(:switchover) { (12 * 60) + 34 } # 12:34 PM
      let(:roster) { build :roster, switchover: }

      it 'is today' do
        expect(call.to_date).to eq(Time.zone.today)
      end

      it 'is the correct time' do
        expect(call.to_fs(:time)).to eq('12:34')
      end
    end
  end
end

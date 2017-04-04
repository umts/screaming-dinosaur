require 'rails_helper'

describe Rotation do
  describe 'generate_assignments' do
    before :each do
      @rotation = create :rotation
      @user_1 = create :user, rotations: [@rotation]
      @user_2 = create :user, rotations: [@rotation]
      @user_3 = create :user, rotations: [@rotation]
      start_date = Date.today
      # A day short of four weeks, to test that the end date
      # is a day short as well
      end_date = (4.weeks.since - 2.days).to_date
      starting_user_id = @user_2.id
      @assignments = @rotation.generate_assignments(
        [@user_1.id, @user_2.id, @user_3.id],
        start_date,
        end_date,
        starting_user_id
      )
      expect(@assignments.size).to be 4
    end
    it 'creates the expected assignments (part 1)' do
      assignment = @assignments[0]
      expect(assignment.user).to eql @user_2 # starts in the correct place
      expect(assignment.rotation).to eql @rotation
      expect(assignment.start_date).to eql Date.today
      expect(assignment.end_date).to eql 6.days.since.to_date
    end
    it 'creates the expected assignments (part 2)' do
      assignment = @assignments[1]
      expect(assignment.user).to eql @user_3
      expect(assignment.rotation).to eql @rotation
      expect(assignment.start_date).to eql 1.week.since.to_date
      expect(assignment.end_date).to eql 13.days.since.to_date
    end
    it 'creates the expected assignments (part 3)' do
      assignment = @assignments[2]
      expect(assignment.user).to eql @user_1 # wraps back around
      expect(assignment.rotation).to eql @rotation
      expect(assignment.start_date).to eql 2.weeks.since.to_date
      expect(assignment.end_date).to eql 20.days.since.to_date
    end
    # this one is significant because there are more weeks than
    # people - just make sure the modular arithmetic works
    it 'creates the expected assignments (part 4)' do
      assignment = @assignments[3]
      expect(assignment.user).to eql @user_2
      expect(assignment.rotation).to eql @rotation
      expect(assignment.start_date).to eql 3.weeks.since.to_date
      expect(assignment.end_date).to eql 26.days.since.to_date
    end
  end
end

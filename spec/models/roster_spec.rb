# frozen_string_literal: true

RSpec.describe Roster do
  describe 'generate_assignments' do
    before do
      @roster = create :roster
      @user1 = roster_user @roster
      @user2 = roster_user @roster
      @user3 = roster_user @roster
    end

    let(:start_date) { Date.new(2019, 1, 1) }
    # A day short of four weeks, to test that the end date
    # is a day short as well
    let(:end_date) { start_date + 4.weeks - 2.days }

    let :call do
      @roster.generate_assignments [@user1.id, @user2.id, @user3.id],
                                   start_date,
                                   end_date,
                                   @user2.id
    end

    it 'creates the correct number of assignments' do
      expect(call.size).to be 4
    end

    it 'creates the expected assignments (part 1)' do
      assignment = call[0]
      expect(assignment.user).to eql @user2 # starts in the correct place
      expect(assignment.roster).to eql @roster
      expect(assignment.start_date).to eql start_date
      expect(assignment.end_date).to eql 6.days.since(start_date).to_date
    end

    it 'creates the expected assignments (part 2)' do
      assignment = call[1]
      expect(assignment.user).to eql @user3
      expect(assignment.roster).to eql @roster
      expect(assignment.start_date).to eql 1.week.since(start_date).to_date
      expect(assignment.end_date).to eql 13.days.since(start_date).to_date
    end

    it 'creates the expected assignments (part 3)' do
      assignment = call[2]
      expect(assignment.user).to eql @user1 # wraps back around
      expect(assignment.roster).to eql @roster
      expect(assignment.start_date).to eql 2.weeks.since(start_date).to_date
      expect(assignment.end_date).to eql 20.days.since(start_date).to_date
    end

    # this one is significant because there are more weeks than
    # people - just make sure the modular arithmetic works
    it 'creates the expected assignments (part 4)' do
      assignment = call[3]
      expect(assignment.user).to eql @user2
      expect(assignment.roster).to eql @roster
      expect(assignment.start_date).to eql 3.weeks.since(start_date).to_date
      expect(assignment.end_date).to eql 26.days.since(start_date).to_date
    end
  end

  describe 'on_call_user' do
    let(:roster) { create :roster, fallback_user: fallback_user }
    let(:fallback_user) { create :user }
    let(:assignment) { create :assignment, roster: roster }
    let(:result) { roster.on_call_user }

    context 'there is a current assignment' do
      before do
        expect(roster).to receive(:assignments)
          .and_return double(current: assignment)
      end

      it 'returns the user of the current assignment' do
        expect(result).to eql assignment.user
      end
    end

    context 'no current assignment' do
      it 'returns the fallback user' do
        expect(result).to eql fallback_user
      end
    end
  end

  describe 'fallback_call_twiml' do
    context 'with a fallback user' do
      let(:fallback_user) { create :user, phone: '+12125551212' }
      let(:roster) { create :roster, fallback_user: fallback_user }
      let(:document) { Nokogiri::XML roster.fallback_call_twiml }

      it 'is a valid TwiML document' do
        expect(document.version).to eql '1.0'
        expect(document.root.name).to eql 'Response'
      end

      it 'apologizes' do
        expect(document.xpath('/Response/Say').count).to be 1
        expect(document.at_xpath('/Response/Say').text)
          .to match(/application error/i)
      end

      it 'calls the fallback user' do
        expect(document.xpath('/Response/Dial').count).to be 1
        expect(document.at_xpath('/Response/Dial').text)
          .to eql fallback_user.phone
      end
    end

    context 'without a fallback user' do
      let(:roster) { create :roster }

      it 'returns nil' do
        expect(roster.fallback_call_twiml).to be_nil
      end
    end
  end

  describe 'fallback_text_twiml' do
    context 'with a fallback user' do
      let(:fallback_user) { create :user, phone: '+12125551212' }
      let(:roster) { create :roster, fallback_user: fallback_user }
      let(:document) { Nokogiri::XML roster.fallback_text_twiml }
      let(:reply) do
        document.at_xpath "/Response/Message[@to='{{From}}']"
      end
      let(:forward) do
        document.at_xpath "/Response/Message[@to='+12125551212']"
      end

      it 'is a valid TwiML document' do
        expect(document.version).to eql '1.0'
        expect(document.root.name).to eql 'Response'
      end

      it 'replies to the texter' do
        expect(reply).to be_present
        expect(reply.text).to match(/application error/i)
      end

      it 'texts the fallback user' do
        expect(forward).to be_present
      end
    end

    context 'without a fallback user' do
      let(:roster) { create :roster }

      it 'returns nil' do
        expect(roster.fallback_text_twiml).to be_nil
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
end

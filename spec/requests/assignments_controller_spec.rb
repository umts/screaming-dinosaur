# frozen_string_literal: true

RSpec.describe AssignmentsController do
  describe 'GET #index.json' do
    let(:roster) { create :roster }
    let(:user) { roster_user(roster) }
    let(:assignment) { create :assignment, roster: roster }
    let!(:own_assignment) do
      create :assignment,
             roster: roster,
             user: user,
             start_date: 1.day.after(assignment.end_date),
             end_date: 2.days.after(assignment.end_date)
    end
    let(:json) { JSON.parse(response.body) }
    before(:each) do
      when_current_user_is user
      get "/rosters/#{roster.id}/assignments.json",
          params: { start_date: 1.month.ago,
                    end_date: 1.month.from_now }
    end

    it 'is a JSON array' do
      expect(json).to be_a Array
    end
    it 'has an object for each assignment' do
      expect(json.count).to be(2)
      expect(json).to all(be_a Hash)
    end

    context 'within an assignment not our own' do
      let(:assignment_object) do
        json.find { |a| a['id'] == "assignment-#{assignment.id}" }
      end

      it 'has a title' do
        expect(assignment_object.fetch('title'))
          .to eq(assignment.user.last_name)
      end
      it 'has a url' do
        get assignment_object.fetch('url')
        expect(response).to have_http_status :ok
      end
      it 'is "all day"' do
        expect(assignment_object.fetch('allDay')).to be(true)
      end
      it 'has an start' do
        start_date = Date.parse(assignment_object.fetch('start'))
        expect(start_date).to eq assignment.start_date
      end
      it 'has an end date' do
        end_date = Date.parse(assignment_object.fetch('end'))
        expect(end_date).to eq 1.day.after(assignment.end_date)
      end
      it 'has an event color' do
        expect(assignment_object.fetch('color')).to eq('var(--secondary)')
      end
    end

    context 'with our own assignment' do
      let(:assignment_object) do
        json.find { |a| a['id'] == "assignment-#{own_assignment.id}" }
      end

      it 'has an "owned" event color' do
        expect(assignment_object.fetch('color')).to eq('var(--info)')
      end
    end
  end
end

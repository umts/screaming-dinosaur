# frozen_string_literal: true

RSpec.describe AssignmentsController do
  describe 'GET #index.json' do
    subject(:json) { response.parsed_body }

    let(:roster) { create :roster }
    let!(:assignment) { create :assignment, roster: }
    let!(:own_assignment) do
      create :assignment, roster:,
                          start_date: 1.day.after(assignment.end_date),
                          end_date: 2.days.after(assignment.end_date)
    end

    before do
      when_current_user_is own_assignment.user
      get "/rosters/#{roster.id}/assignments.json",
          params: { start_date: 1.month.ago, end_date: 1.month.from_now }
    end

    it { is_expected.to be_a Array }

    it { is_expected.to all(be_a Hash) }

    it 'has an entry for each assignment' do
      expect(json.count).to be(2)
    end

    context 'with an assignment not our own' do
      subject(:assignment_object) do
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
        expect(assignment_object.fetch('color')).to eq('var(--bs-secondary)')
      end
    end

    context 'with our own assignment' do
      subject(:assignment_object) do
        json.find { |a| a['id'] == "assignment-#{own_assignment.id}" }
      end

      it 'has an "owned" event color' do
        expect(assignment_object.fetch('color')).to eq('var(--bs-info)')
      end
    end
  end

  describe 'DELETE /rosters/:roster_id/assignments/:id' do
    subject(:submit) { delete "/rosters/#{roster.id}/assignments/#{assignment.id}" }

    let(:roster) { create :roster }
    let!(:assignment) { create :assignment, roster: }
    let(:roster_admin) { create :user, rosters: [roster] }

    context 'when the current user is an admin in the roster' do
      before do
        roster_admin.membership_in(roster).update admin: true
        when_current_user_is roster_admin
      end

      it 'deletes an Assignment' do
        expect { submit }.to change(Assignment, :count).by(-1)
      end

      it 'deletes the target Assignment' do
        submit
        expect(Assignment.find_by(id: roster.id)).to be_nil
      end

      it { is_expected.to redirect_to("/rosters/#{roster.to_param}/assignments") }

      it 'sends a notification to the owner of the assignment' do
        expect { submit }.to have_enqueued_email(AssignmentsMailer, :deleted_assignment)
      end
    end

    context 'when the current user is not an admin in the roster' do
      before { when_current_user_is assignment.user }

      it 'does not delete an Assignment' do
        expect { submit }.not_to change(Assignment, :count)
      end
    end
  end
end

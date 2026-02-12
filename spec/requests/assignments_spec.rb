# frozen_string_literal: true

RSpec.describe 'Assignments' do
  shared_context 'with valid attributes' do
    let(:attributes) do
      { user_id: create(:user, rosters: [roster]).id, start_date: Date.current, end_date: Date.tomorrow }
    end
  end

  shared_context 'with invalid attributes' do
    let(:attributes) { { user_id: nil, start_date: nil, end_date: nil } }
  end

  describe 'GET /rosters/:roster_id/assignments.json' do
    subject(:call) do
      get "/rosters/#{roster.slug}/assignments.json", params: { start_date: 1.month.ago, end_date: 1.month.from_now }
    end

    let(:roster) { create :roster }

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      let!(:own_assignment) do
        create :assignment, roster:, user: current_user, start_date: Date.current, end_date: Date.tomorrow
      end
      let!(:other_assignment) do
        create :assignment, roster:, user: create(:user, rosters: [roster]),
                            start_date: 2.days.from_now, end_date: 4.days.from_now
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with calendar data' do
        call
        expect(response.parsed_body).to contain_exactly(
          { 'id' => "assignment-#{own_assignment.id}",
            'title' => own_assignment.user.last_name,
            'url' => edit_assignment_path(own_assignment),
            'allDay' => true,
            'start' => own_assignment.start_date.iso8601,
            'end' => (own_assignment.end_date + 1).iso8601,
            'color' => 'var(--bs-primary)' },
          { 'id' => "assignment-#{other_assignment.id}",
            'title' => other_assignment.user.last_name,
            'url' => edit_assignment_path(other_assignment),
            'allDay' => true,
            'start' => other_assignment.start_date.iso8601,
            'end' => (other_assignment.end_date + 1).iso8601,
            'color' => 'var(--bs-secondary)' }
        )
      end
    end
  end

  describe 'GET /rosters/:roster_id/assignments.csv' do
    subject(:call) { get "/rosters/#{roster.slug}/assignments.csv" }

    let(:roster) { create :roster }

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      let(:users) { create_list :user, 2, rosters: [roster] }
      let!(:current_assignment) do
        create :assignment, roster:, user: users[0], start_date: Date.current, end_date: 1.day.from_now
      end
      let!(:past_assignment) do
        create :assignment, roster:, user: users[1], start_date: 2.days.ago, end_date: 1.day.ago
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with assignment data for the given roster' do
        call
        row1 = [roster.name, users[1].email, users[1].first_name, users[1].last_name,
                past_assignment.start_date.to_fs(:db), past_assignment.end_date.to_fs(:db),
                past_assignment.created_at.to_fs(:db), past_assignment.updated_at.to_fs(:db)].join ','
        row2 = [roster.name, users[0].email, users[0].first_name, users[0].last_name,
                current_assignment.start_date.to_fs(:db), current_assignment.end_date.to_fs(:db),
                current_assignment.created_at.to_fs(:db), current_assignment.updated_at.to_fs(:db)].join ','
        expect(response.body).to eq(<<~CSV)
          roster,email,first_name,last_name,start_date,end_date,created_at,updated_at
          #{row1}
          #{row2}
        CSV
      end
    end
  end

  describe 'GET /rosters/:roster_id/assignments/new' do
    subject(:call) { get "/rosters/#{roster.slug}/assignments/new", params: params }

    let(:roster) { create :roster }
    let(:params) { nil }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as an admin of the roster with a date param' do
      include_context 'when logged in as an admin of the roster'

      let(:params) { { date: 1.week.from_now } }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /assignments/:id/edit' do
    subject(:call) { get "/assignments/#{assignment.id}/edit" }

    let(:roster) { create :roster }
    let(:assignment) { create :assignment, roster: }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:roster_id/assignments' do
    subject(:submit) { post "/rosters/#{roster.slug}/assignments", params: { assignment: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with valid attributes'

      it 'redirects to the roster' do
        submit
        expect(response).to redirect_to roster_path(roster)
      end

      it 'creates a new assignment' do
        expect { submit }.to change(Assignment, :count).by(1)
      end

      it 'creates a new assignment with the given attributes' do
        submit
        expect(Assignment.last).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with invalid attributes'

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /assignments/:id' do
    subject(:submit) { patch "/assignments/#{assignment.id}", params: { assignment: attributes } }

    let(:roster) { create :roster }
    let(:assignment) { create(:assignment, roster:) }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with valid attributes'

      it 'redirects to the roster' do
        submit
        expect(response).to redirect_to roster_path(roster)
      end

      it 'updates the assignment with the given attributes' do
        submit
        expect(assignment.reload).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with invalid attributes'

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /assignments/:id' do
    subject(:submit) { delete "/assignments/#{assignment.id}" }

    let(:roster) { create :roster }
    let(:assignment) { create :assignment, roster: }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to(roster_path(roster))
      end

      it 'destroys the assignment' do
        submit
        expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

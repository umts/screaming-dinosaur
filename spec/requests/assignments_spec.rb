# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assignments' do
  shared_context 'with valid attributes' do
    let(:attributes) do
      { user_id: create(:user, rosters: [roster]).id, end_datetime: Time.zone.tomorrow.middle_of_day }
    end
  end

  shared_context 'with invalid attributes' do
    let(:attributes) { { user_id: nil, end_datetime: nil } }
  end

  describe 'GET /rosters/:roster_id/assignments.json' do
    subject(:call) do
      get "/rosters/#{roster.slug}/assignments.json", params: { start_date: Date.current, end_date: Date.tomorrow }
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

      let!(:past_assignment) { create :assignment, roster:, end_datetime: Date.yesterday.at_middle_of_day }
      let!(:open_assignment) { create :assignment, roster:, end_datetime: Date.current.at_middle_of_day }
      let!(:taken_assignment) do
        create :assignment, roster:,
                            user: create(:user, rosters: [roster]),
                            end_datetime: Date.tomorrow.at_middle_of_day
      end
      let!(:own_assignment) do
        create :assignment, roster:, user: current_user, end_datetime: 2.days.from_now.at_middle_of_day
      end

      before { create :assignment, roster:, end_datetime: 3.days.from_now.at_middle_of_day }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with calendar data' do
        call
        expect(response.parsed_body).to contain_exactly(
          a_hash_including(
            'id' => "assignment-#{open_assignment.id}",
            'title' => 'Open',
            'url' => edit_assignment_path(open_assignment),
            'start' => past_assignment.end_datetime.iso8601,
            'end' => open_assignment.end_datetime.iso8601,
            'color' => 'var(--bs-secondary)'
          ),
          a_hash_including(
            'id' => "assignment-#{taken_assignment.id}",
            'title' => taken_assignment.user.last_name,
            'url' => edit_assignment_path(taken_assignment),
            'start' => open_assignment.end_datetime.iso8601,
            'end' => taken_assignment.end_datetime.iso8601,
            'color' => 'var(--bs-secondary)'
          ),
          a_hash_including(
            'id' => "assignment-#{own_assignment.id}",
            'title' => own_assignment.user.last_name,
            'url' => edit_assignment_path(own_assignment),
            'start' => taken_assignment.end_datetime.iso8601,
            'end' => own_assignment.end_datetime.iso8601,
            'color' => 'var(--bs-primary)'
          )
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

      let(:roster) { create :roster, created_at: 2.days.ago.middle_of_day }
      let(:users) { create_list :user, 2, rosters: [roster] }
      let!(:assignments) do
        [
          create(:assignment, roster:, user: users.first, end_datetime: Date.current.middle_of_day),
          create(:assignment, roster:, user: users.second, end_datetime: Date.yesterday.middle_of_day)
        ]
      end

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with assignment data for the given roster' do
        call
        row1 = [roster.name, users.second.email, users.second.first_name, users.second.last_name,
                roster.created_at.iso8601,
                assignments.second.end_datetime.iso8601,
                assignments.second.created_at.iso8601,
                assignments.second.updated_at.iso8601].join(',')
        row2 = [roster.name, users.first.email, users.first.first_name, users.first.last_name,
                assignments.second.end_datetime.iso8601,
                assignments.first.end_datetime.iso8601,
                assignments.first.created_at.iso8601,
                assignments.first.updated_at.iso8601].join(',')
        expect(response.body).to eq(<<~CSV)
          roster,email,first_name,last_name,start,end,created_at,updated_at
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

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

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

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:roster_id/assignments' do
    subject(:submit) { post "/rosters/#{roster.slug}/assignments", params: { assignment: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster assigning themselves' do
      include_context 'when logged in as a member of the roster'

      let(:attributes) { { user_id: current_user.id, end_datetime: Time.zone.tomorrow.middle_of_day } }

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

    context 'when logged in as a member of the roster assigning someone else' do
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

    context 'when logged in as user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster assigning themselves' do
      include_context 'when logged in as a member of the roster'

      let(:attributes) { { user_id: current_user.id } }

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

    context 'when logged in as a member of the roster assigning someone else' do
      include_context 'when logged in as a member of the roster'

      let(:attributes) { { user_id: create(:user, rosters: [roster]).id } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster changing dates' do
      include_context 'when logged in as a member of the roster'

      let(:attributes) { { end_datetime: Time.zone.tomorrow.middle_of_day } }

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

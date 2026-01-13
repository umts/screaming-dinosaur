# frozen_string_literal: true

RSpec.describe 'Assignments' do
  describe 'GET /rosters/:id/assignments' do
    subject(:call) { get "/rosters/#{roster.id}/assignments", headers: }

    let(:roster) { create :roster }
    let(:headers) { nil }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in' do
      before { login_as create(:user) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'with a csv content type' do
      let(:headers) { { 'ACCEPT' => 'text/csv' } }
      let(:users) { create_list :user, 2, rosters: [roster] }
      let!(:current_assignment) do
        create :assignment, roster:, user: users[0], start_date: Date.current, end_date: 1.day.from_now
      end
      let!(:past_assignment) do
        create :assignment, roster:, user: users[1], start_date: 2.days.ago, end_date: 1.day.ago
      end

      before { login_as create(:user) }

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

  describe 'GET /rosters/:id/assignments/new' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/new", params: { date: Date.current } }

    let(:roster) { create :roster }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in' do
      before { login_as create(:user) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/assignments/:id/edit' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/#{assignment.id}/edit" }

    let(:roster) { create :roster }
    let(:assignment) { create :assignment }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in' do
      before { login_as create(:user) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:id/assignments' do
    subject(:submit) { post "/rosters/#{roster.id}/assignments", params: { assignment: attributes } }

    let(:roster) { create :roster }

    context 'when not logged in' do
      let(:attributes) { { user_id: create(:user).id, start_date: Date.current, end_date: Date.tomorrow } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a normal user and assigning yourself' do
      let(:user) { create :user, memberships: [build(:membership, roster:)] }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as user }

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to roster_assignments_path(roster)
      end

      it 'creates a new assignment' do
        expect { submit }.to change(Assignment, :count).by(1)
      end

      it 'creates a new assignment with the given attributes' do
        submit
        expect(Assignment.last).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end

    context 'when logged in as a normal user and assigning someone else' do
      let(:user) { create :user }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as create(:user) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin and assigning someone else' do
      let(:user) { create :user, memberships: [build(:membership, roster:)] }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to roster_assignments_path(roster)
      end

      it 'creates a new assignment' do
        expect { submit }.to change(Assignment, :count).by(1)
      end

      it 'creates a new assignment with the given attributes' do
        submit
        expect(Assignment.last).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end
  end

  describe 'PATCH /rosters/:id/assignments/:id' do
    subject(:submit) { patch "/rosters/#{roster.id}/assignments/#{assignment.id}", params: { assignment: attributes } }

    let(:roster) { create :roster }
    let!(:assignment) { create(:assignment, roster:) }

    context 'when not logged in' do
      let(:attributes) { { user_id: create(:user).id, start_date: Date.current, end_date: Date.tomorrow } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a normal user and assigning yourself' do
      let(:user) { create :user, memberships: [build(:membership, roster:)] }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as user }

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to roster_assignments_path(roster)
      end

      it 'updates the assignment with the given attributes' do
        submit
        expect(assignment.reload).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end

    context 'when logged in as a normal user and assigning someone else' do
      let(:user) { create :user }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as create(:user) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin and assigning someone else' do
      let(:user) { create :user, memberships: [build(:membership, roster:)] }
      let(:attributes) { { user_id: user.id, start_date: Date.current, end_date: Date.tomorrow } }

      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to roster_assignments_path(roster)
      end

      it 'updates the assignment with the given attributes' do
        submit
        expect(assignment.reload).to have_attributes(attributes.merge('roster_id' => roster.id))
      end
    end
  end

  describe 'DELETE /rosters/:id/assignments/:id' do
    subject(:submit) { delete "/rosters/#{roster.id}/assignments/#{assignment.id}" }

    let(:roster) { create :roster }
    let(:assignment) { create :assignment, roster: }

    context 'when logged in as an admin in another roster' do
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin in the roster' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

      it 'redirects to all assignments' do
        submit
        expect(response).to redirect_to(roster_assignments_path(roster))
      end

      it 'destroys the assignment' do
        submit
        expect(Assignment.find_by(id: assignment.id)).to be_nil
      end
    end
  end
end

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
end

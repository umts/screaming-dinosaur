# frozen_string_literal: true

RSpec.describe 'Assignments' do
  shared_context 'when logged in as a roster admin' do
    let(:admin) { create(:user).tap { |user| create :membership, roster:, user:, admin: true } }

    before { set_user admin }
  end

  describe 'GET /rosters/:id/assignments' do
    subject(:call) { get "/rosters/#{roster.id}/assignments", headers: }

    let(:roster) { create :roster }
    let(:user1) { create(:user).tap { |user| create :membership, roster:, user: } }
    let(:user2) { create(:user).tap { |user| create :membership, roster:, user: } }
    let!(:assignment1) do
      create :assignment, roster:, user: user1, start_date: Date.current, end_date: 1.day.from_now
    end
    let!(:assignment2) do
      create :assignment, roster:, user: user2, start_date: 2.days.ago, end_date: 1.day.ago
    end

    include_context 'when logged in as a roster admin'

    context 'with a csv acceptance header' do
      let(:headers) { { accept: 'text/csv' } }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with assignment data for the given roster' do
        call
        row1 = [roster.name, user2.email, user2.first_name, user2.last_name,
                assignment2.start_date.to_fs(:db), assignment2.end_date.to_fs(:db),
                assignment2.created_at.to_fs(:db), assignment2.updated_at.to_fs(:db)].join ','
        row2 = [roster.name, user1.email, user1.first_name, user1.last_name,
                assignment1.start_date.to_fs(:db), assignment1.end_date.to_fs(:db),
                assignment1.created_at.to_fs(:db), assignment1.updated_at.to_fs(:db)].join ','
        expect(response.body).to eq(<<~CSV)
          roster,email,first_name,last_name,start_date,end_date,created_at,updated_at
          #{row1}
          #{row2}
        CSV
      end
    end
  end
end

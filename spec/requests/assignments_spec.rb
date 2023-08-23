# frozen_string_literal: true

RSpec.describe 'Assignments' do
  describe 'GET /rosters/:id/assignments/generate_by_weekday' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/generate_by_weekday" }

    let(:roster) { create :roster }
    let(:admin) { create :user }

    before do
      create :membership, roster: roster, user: admin, admin: true
      set_user admin
    end

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end
  end

  describe 'GET /rosters/:id/assignments' do
    subject(:call) { get "/rosters/#{roster.id}/assignments", headers: headers }

    let(:roster) { create :roster }
    let(:admin) { create(:user).tap { |user| create :membership, roster: roster, user: user, admin: true } }
    let(:user1) { create(:user).tap { |user| create :membership, roster: roster, user: user } }
    let(:user2) { create(:user).tap { |user| create :membership, roster: roster, user: user } }
    let!(:assignment1) do
      create :assignment, roster: roster, user: user1, start_date: Date.current, end_date: 1.day.from_now
    end
    let!(:assignment2) do
      create :assignment, roster: roster, user: user2, start_date: 2.days.ago, end_date: 1.day.ago
    end

    before { set_user admin }

    context 'with a csv acceptance header' do
      let(:headers) { { accept: 'text/csv' } }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      it 'responds with assignment data for the given roster' do
        call
        row1 = [roster.name, user2.first_name, user2.last_name, assignment2.start_date.iso8601,
                assignment2.end_date.iso8601, assignment2.created_at.iso8601, assignment2.updated_at.iso8601].join ','
        row2 = [roster.name, user1.first_name, user1.last_name, assignment1.start_date.iso8601,
                assignment1.end_date.iso8601, assignment1.created_at.iso8601, assignment1.updated_at.iso8601].join ','
        expect(response.body).to eq(<<~CSV)
          roster,first_name,last_name,start_date,end_date,created_at,updated_at
          #{row1}
          #{row2}
        CSV
      end
    end
  end
end

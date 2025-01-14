# frozen_string_literal: true

RSpec.describe 'Assignment Weekday Generators' do
  shared_context 'when logged in as a roster admin' do
    let(:admin) { create(:user).tap { |user| create :membership, roster:, user:, admin: true } }

    before { set_user admin }
  end

  describe 'GET /rosters/:id/assignments/generate_by_weekday' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/generate_by_weekday" }

    let(:roster) { create :roster }

    include_context 'when logged in as a roster admin'

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end
  end

  describe 'POST /rosters/:id/assignments/generate_by_weekday' do
    subject(:submit) { post "/rosters/#{roster.id}/assignments/generate_by_weekday", params: }

    let(:roster) { create :roster }
    let(:user) { create(:user).tap { |user| create :membership, roster:, user: } }

    include_context 'when logged in as a roster admin'

    context 'with valid params' do
      let(:params) do
        { assignment_weekday_generator: { user_id: user.id,
                                          start_date: Date.current.beginning_of_week(:sunday) + 3,
                                          end_date: 1.week.from_now.to_date.beginning_of_week(:sunday) + 3,
                                          start_weekday: 2,
                                          end_weekday: 4 } }
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(2)
      end

      it 'creates new assignments with the correct attributes' do
        submit
        expect(Assignment.last(2).collect(&:attributes)).to contain_exactly(
          a_hash_including('roster_id' => roster.id,
                           'user_id' => user.id,
                           'start_date' => Date.current.beginning_of_week(:sunday) + 3,
                           'end_date' => Date.current.beginning_of_week(:sunday) + 4),
          a_hash_including('roster_id' => roster.id,
                           'user_id' => user.id,
                           'start_date' => 1.week.from_now.to_date.beginning_of_week(:sunday) + 2,
                           'end_date' => 1.week.from_now.to_date.beginning_of_week(:sunday) + 3)
        )
      end
    end

    context 'with invalid generator params' do
      let(:params) { {} }

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid assignment params' do
      let(:params) do
        { assignment_weekday_generator: { user_id: user.id,
                                          start_date: Date.current,
                                          end_date: Date.current,
                                          start_weekday: Date.current.wday,
                                          end_weekday: Date.current.wday } }
      end

      before { create :assignment, roster:, user:, start_date: Date.current, end_date: Date.current }

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

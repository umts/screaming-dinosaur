# frozen_string_literal: true

RSpec.describe 'Weekday Assigners' do
  describe 'GET /rosters/:roster_id/assign_weekdays' do
    subject(:call) { get "/rosters/#{roster.slug}/assign_weekdays" }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with an forbidden status' do
        call
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when logged in as the roster admin' do
      include_context 'when logged in as an admin of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters/:roster_id/assign_weekdays' do
    subject(:submit) { post "/rosters/#{roster.slug}/assign_weekdays", params: { weekday_assigner: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      let(:attributes) { { start_date: Date.current } }

      it 'responds with an forbidden status' do
        submit
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'

      let(:user) { create :user, rosters: [roster] }
      let(:attributes) do
        { user_id: user.id,
          start_date: Date.current.beginning_of_week(:sunday) + 3,
          end_date: 1.week.from_now.to_date.beginning_of_week(:sunday) + 3,
          start_weekday: 2,
          end_weekday: 4 }
      end

      it 'redirects to the roster assignments page' do
        submit
        expect(response).to redirect_to roster_path(roster, date: Date.current.beginning_of_week(:sunday) + 3)
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(2)
      end

      it 'creates new assignments with the correct attributes' do
        submit
        expect(Assignment.last(2)).to contain_exactly(
          have_attributes('roster_id' => roster.id,
                          'user_id' => user.id,
                          'start_date' => Date.current.beginning_of_week(:sunday) + 3,
                          'end_date' => Date.current.beginning_of_week(:sunday) + 4),
          have_attributes('roster_id' => roster.id,
                          'user_id' => user.id,
                          'start_date' => 1.week.from_now.to_date.beginning_of_week(:sunday) + 2,
                          'end_date' => 1.week.from_now.to_date.beginning_of_week(:sunday) + 3)
        )
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'

      let(:attributes) { { start_date: Date.current } }

      it 'responds with an unprocessable content status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

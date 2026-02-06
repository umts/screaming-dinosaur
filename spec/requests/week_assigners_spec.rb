# frozen_string_literal: true

RSpec.describe 'Week Assigners' do
  describe 'GET /rosters/:roster_id/assign_weeks' do
    subject(:call) { get "/rosters/#{roster.slug}/assign_weeks" }

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

  describe 'POST /rosters/:roster_id/assign_weeks' do
    subject(:submit) { post "/rosters/#{roster.slug}/assign_weeks", params: { week_assigner: attributes } }

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

      let(:attributes) do
        { start_date: start_date,
          end_date: start_date + 18.days,
          starting_user_id: users.first.id,
          user_ids: users.map(&:id) }
      end
      let(:users) { create_list :user, 2, rosters: [roster] }
      let(:start_date) { Date.current.beginning_of_week(:sunday) }

      it 'redirects to the roster assignments page' do
        submit
        expect(response).to redirect_to roster_path(roster, date: start_date)
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(3)
      end

      it 'creates new assignments with the right attributes' do
        submit
        expect(Assignment.last(3)).to contain_exactly(
          have_attributes('roster_id' => roster.id, 'user_id' => users.first.id,
                          'start_date' => start_date + 2.weeks, 'end_date' => start_date + 2.weeks + 4.days),
          have_attributes('roster_id' => roster.id, 'user_id' => users.second.id,
                          'start_date' => start_date + 1.week, 'end_date' => start_date + 1.week + 6.days),
          have_attributes('roster_id' => roster.id, 'user_id' => users.first.id,
                          'start_date' => start_date, 'end_date' => start_date + 6.days)
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

# frozen_string_literal: true

RSpec.describe 'RotationGeneratorsController' do
  shared_context 'when logged in as a roster admin' do
    let(:admin) { create(:user).tap { |user| create :membership, roster:, user:, admin: true } }

    before { set_user admin }
  end

  describe 'GET assignments/rotation_generator' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/generate_rotation" }

    let(:roster) { create :roster }
    let(:user1) { create(:user).tap { |user| create :membership, roster:, user: } }

    include_context 'when logged in as a roster admin'

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end
  end

  describe 'POST assignments/generate_rotation' do
    subject(:submit) { post "/rosters/#{roster.id}/assignments/generate_rotation", params: }

    let(:roster) { create :roster }
    let(:user1) { create(:user).tap { |user| create :membership, roster:, user: } }
    let(:start_date) { Date.current.beginning_of_week(:sunday) }

    include_context 'when logged in as a roster admin'

    context 'with valid params' do
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 1.week.from_now.end_of_week(:sunday),
                                           starting_user_id: user1.id,
                                           user_ids: [user1.id, admin.id] } }
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(2)
      end

      it 'redirects to the roster assignments page' do
        submit
        expect(response).to redirect_to roster_assignments_path(roster, date: start_date)
      end
    end

    context 'with the end date before the start' do
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 2.months.ago,
                                           starting_user_id: user1.id,
                                           user_ids: [user1.id, admin.id] } }
      end

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with the starting user not in the roster' do
      let(:mystery_user) { create :user }
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 2.months.ago,
                                           starting_user_id: mystery_user.id,
                                           user_ids: [user1.id, admin.id] } }
      end

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

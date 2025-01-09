# frozen_string_literal: true

RSpec.describe 'Assignments Generate Rotation' do
  shared_context 'when logged in as a roster admin' do
    let(:admin) { create(:user).tap { |user| create :membership, roster:, user:, admin: true } }

    before { set_user admin }
  end

  describe 'GET assignments/generate_rotation' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/generate_rotation" }

    let(:roster) { create :roster }
    let(:user1) { create(:user).tap { |user| create :membership, roster:, user: } }

    include_context 'when logged in as a roster admin'

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end

    context 'when logged in as a normal user' do
      before { set_user user1 }

      it 'responds with an unauthorized status' do
        call
        expect(response).to have_http_status :unauthorized
      end
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
                                           end_date: start_date + 18.days,
                                           starting_user_id: user1.id,
                                           user_ids: [admin.id, user1.id] } }
      end

      let(:attributes) do
        [{ roster_id: roster.id,
           user_id: user1.id,
           start_date: start_date + 2.weeks,
           end_date: start_date + 2.weeks + 4.days },
         { roster_id: roster.id,
           user_id: admin.id,
           start_date: start_date + 1.week,
           end_date: start_date + 1.week + 6.days },
         { roster_id: roster.id,
           user_id: user1.id,
           start_date: start_date,
           end_date: start_date + 6.days }]
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(3)
      end

      it 'creates new assignments with the right attributes' do
        submit
        attribute_sets = Assignment.last(3).collect do |assignment|
          assignment.attributes.slice('roster_id', 'user_id', 'start_date', 'end_date').symbolize_keys
        end
        expect(attribute_sets).to match_array(attributes)
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

    context 'with a start date that interferes with another assignment' do
      let(:other_params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: start_date + 6.days,
                                           starting_user_id: user1.id,
                                           user_ids: [user1.id] } }
      end
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: start_date + 18.days,
                                           starting_user_id: user1.id,
                                           user_ids: [admin.id, user1.id] } }
      end

      before { post "/rosters/#{roster.id}/assignments/generate_rotation", params: other_params }

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status :unprocessable_entity
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
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when no users are selected' do
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 1.week.from_now.end_of_week(:sunday),
                                           starting_user_id: user1.id,
                                           user_ids: [] } }
      end

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when you are an admin but not in the roster' do
      let(:other_roster) { create :roster }
      let(:admin) { create(:user).tap { |user| create :membership, roster: other_roster, user:, admin: true } }
      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 1.week.from_now.end_of_week(:sunday),
                                           starting_user_id: user1.id,
                                           user_ids: [user1.id] } }
      end

      before { set_user admin }

      it 'responds with an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when you are a normal user' do
      before { set_user user1 }

      let(:params) do
        { assignment_rotation_generator: { start_date: start_date,
                                           end_date: 1.week.from_now.end_of_week(:sunday),
                                           starting_user_id: user1.id,
                                           user_ids: [user1.id] } }
      end

      it 'responds with an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

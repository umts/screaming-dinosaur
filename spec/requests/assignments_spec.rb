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
      let(:attributes) do
        [{ roster_id: roster.id,
           user_id: user.id,
           start_date: Date.current.beginning_of_week(:sunday) + 3,
           end_date: Date.current.beginning_of_week(:sunday) + 4 },
         { roster_id: roster.id,
           user_id: user.id,
           start_date: 1.week.from_now.to_date.beginning_of_week(:sunday) + 2,
           end_date: 1.week.from_now.to_date.beginning_of_week(:sunday) + 3 }]
      end

      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(2)
      end

      it 'creates new assignments with the correct attributes' do
        submit
        attribute_sets = Assignment.last(2).collect do |assignment|
          assignment.attributes.slice('roster_id', 'user_id', 'start_date', 'end_date').symbolize_keys
        end
        expect(attribute_sets).to match_array(attributes)
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

  describe 'GET assignments/generate_rotation' do
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

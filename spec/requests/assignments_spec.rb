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

  describe 'POST /rosters/:id/assignments/generate_rotation' do
    subject(:submit) { post "/rosters/#{roster.id}/assignments/generate_rotation", params: }

    let(:roster) { create :roster }
    let(:user) { create(:user).tap { |user| create :membership, roster:, user: } }
    
    include_context 'when logged in as a roster admin'

    context 'with valid params' do
      let(:params) do
        { start_date: 3.weeks.ago.beginning_of_week(:sunday),
          end_date: 1.week.ago.beginning_of_week(:sunday) + 1,
          user_ids: [ admin.id, user.id ],
          starting_user_id: admin.id }
      end
      # Add more checks
      it 'creates new assignments' do
        expect { submit }.to change(Assignment, :count).by(2)
      end
    end

    context 'with invalid params' do
      let(:params) { {} }
      # No idea if it actually responds this way
      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'the admin is not in the roster' do
      let(:params) do
        { start_date: 3.weeks.ago.beginning_of_week(:sunday),
          end_date: 1.week.ago.beginning_of_week(:sunday) + 1,
          user_ids: [ user.id ],
          starting_user_id: admin.id }
      end
      #Write this better
      it 'responds with an error' do
        expect { submit }.to change(Assignment, :count).by(0)
      end
    end
  end

  context 'the user is not an admin' do
    before { set_user user }
end

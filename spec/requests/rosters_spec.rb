# frozen_string_literal: true

RSpec.describe 'Rosters' do
  shared_context 'with valid attributes' do
    let(:attributes) { { name: 'Test Roster', phone: '14135451451', switchover_time: '13:15' } }
  end

  shared_context 'with invalid attributes' do
    let(:attributes) { { name: nil, phone: nil, switchover_time: nil } }
  end

  describe 'GET /rosters' do
    subject(:call) { get '/rosters' }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in' do
      let(:current_user) { create :user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id' do
    subject(:call) { get "/rosters/#{roster.slug}" }

    let(:roster) { create :roster }

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id.json' do
    subject(:call) { get "/rosters/#{roster.slug}", headers: { 'ACCEPT' => 'application/json' }, params: params }

    let(:roster) { create :roster }
    let(:params) { nil }

    context 'when logged in as a user unrelated to the roster' do
      include_context 'when logged in as a user unrelated to the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in with an api key' do
      let(:params) { { api_key: 'test api key' } }

      before { allow(Rails.application).to receive(:credentials).and_return({ api_key: 'test api key' }) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when nobody is on call' do
      include_context 'when logged in as a member of the roster'

      it 'responds with roster data' do
        call
        expect(response.parsed_body).to eq({
          id: roster.id,
          name: roster.name,
          slug: roster.slug,
          phone: roster.phone,
          on_call: nil
        }.stringify_keys)
      end
    end

    context 'when somebody is on call' do
      include_context 'when logged in as a member of the roster'

      let(:on_call_user) { create :user, rosters: [roster] }
      let!(:assignment) do
        create(:assignment, roster:, user: on_call_user, start_date: Date.yesterday, end_date: Date.tomorrow)
      end

      it 'responds with roster data' do
        call
        expect(response.parsed_body).to eq({
          id: roster.id,
          name: roster.name,
          slug: roster.slug,
          phone: roster.phone,
          on_call: {
            last_name: on_call_user.last_name,
            first_name: on_call_user.first_name,
            until: assignment.effective_end_datetime.iso8601
          }
        }.deep_stringify_keys)
      end
    end

    context 'when there is an upcoming assignment' do
      include_context 'when logged in as a member of the roster'

      let(:upcoming_user) { create :user, rosters: [roster] }

      before do
        create(:assignment, roster:, user: upcoming_user, start_date: Date.tomorrow, end_date: 2.days.from_now)
      end

      it 'responds with roster data' do
        call
        expect(response.parsed_body).to eq({
          id: roster.id,
          name: roster.name,
          slug: roster.slug,
          phone: roster.phone,
          on_call: nil,
          upcoming: {
            last_name: upcoming_user.last_name,
            first_name: upcoming_user.first_name
          }
        }.deep_stringify_keys)
      end
    end
  end

  describe 'GET /rosters/new' do
    subject(:call) { get '/rosters/new' }

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin' do
      let(:current_user) { create :user, admin: true }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/edit' do
    subject(:call) { get "/rosters/#{roster.slug}/edit" }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters' do
    subject(:submit) { post '/rosters', params: { roster: attributes } }

    context 'when logged in as a roster admin' do
      include_context 'with valid attributes'

      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a system admin with valid attributes' do
      include_context 'with valid attributes'

      let(:current_user) { create :user, admin: true }

      it 'redirects to all rosters' do
        submit
        expect(response).to redirect_to(rosters_path)
      end

      it 'creates a roster' do
        expect { submit }.to change(Roster, :count).by(1)
      end

      it 'creates a roster with the given attributes' do
        submit
        expect(Roster.last).to have_attributes(
          attributes.except(:switchover_time).merge(switchover: (13.hours + 15.minutes).in_minutes)
        )
      end
    end

    context 'when logged in as a system admin with invalid attributes' do
      include_context 'with invalid attributes'

      let(:current_user) { create :user, admin: true }

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create a roster' do
        expect { submit }.not_to change(Roster, :count)
      end
    end
  end

  describe 'PATCH /rosters/:id' do
    subject(:submit) { patch "/rosters/#{roster.slug}", params: { roster: attributes } }

    let(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'
      include_context 'with valid attributes'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster with valid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with valid attributes'

      it 'redirects to all rosters' do
        submit
        expect(response).to redirect_to(rosters_path)
      end

      it 'updates the roster with the given attributes' do
        submit
        expect(roster.reload).to have_attributes(
          attributes.except(:switchover_time).merge(switchover: (13.hours + 15.minutes).in_minutes)
        )
      end
    end

    context 'when logged in as an admin of the roster with invalid attributes' do
      include_context 'when logged in as an admin of the roster'
      include_context 'with invalid attributes'

      it 'responds with an unprocessable entity status' do
        submit
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not update the roster' do
        expect { submit }.not_to(change { roster.reload.attributes })
      end
    end
  end

  describe 'DELETE /rosters/:id' do
    subject(:submit) { delete "/rosters/#{roster.slug}" }

    let!(:roster) { create :roster }

    context 'when logged in as a member of the roster' do
      include_context 'when logged in as a member of the roster'

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin of the roster' do
      include_context 'when logged in as an admin of the roster'

      it 'redirects to all rosters' do
        submit
        expect(response).to redirect_to(rosters_path)
      end

      it 'destroys the given roster' do
        submit
        expect { roster.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

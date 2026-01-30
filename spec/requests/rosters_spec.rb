# frozen_string_literal: true

RSpec.describe 'Rosters' do
  describe 'GET /rosters' do
    subject(:call) { get '/rosters' }

    context 'when logged in as a normal user' do
      let(:current_user) { create :user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id' do
    subject(:call) { get "/rosters/#{roster.id}", headers: { 'ACCEPT' => 'application/json' }, params: params }

    let(:roster) { create :roster }
    let(:params) { nil }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a user' do
      let(:current_user) { create :user }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end

      context 'when nobody is on call' do
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

    context 'with an api key' do
      let(:params) { { api_key: 'test api key' } }

      before { allow(Rails.application).to receive(:credentials).and_return({ api_key: 'test api key' }) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/new' do
    subject(:call) { get '/rosters/new' }

    context 'when logged in as a normal user' do
      let(:current_user) { create :user }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/:id/edit' do
    subject(:call) { get "/rosters/#{roster.id}/edit" }

    let(:roster) { create :roster }

    context 'when logged in as an admin for a different roster' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /rosters' do
    subject(:submit) { post '/rosters', params: { roster: attributes } }

    context 'when logged in as a normal user' do
      let(:attributes) { nil }

      let(:current_user) { create :user }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      context 'with valid attributes' do
        let(:attributes) { { name: 'Test Roster', phone: '14135451451', switchover_time: '13:15' } }

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

      context 'with invalid attributes' do
        let(:attributes) { { name: nil, phone: nil, switchover_time: nil } }

        it 'responds with an unprocessable entity status' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'does not create a roster' do
          expect { submit }.not_to change(Roster, :count)
        end
      end
    end
  end

  describe 'PATCH /rosters/:id' do
    subject(:submit) { patch "/rosters/#{roster.id}", params: { roster: attributes } }

    let!(:roster) { create :roster }

    context 'when logged in as an admin for a different roster' do
      let(:attributes) { nil }

      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      context 'with valid attributes' do
        let(:attributes) { { name: 'Test Roster', phone: '14135451451', switchover_time: '13:15' } }

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

      context 'with invalid attributes' do
        let(:attributes) { { name: nil, phone: nil, switchover_time: nil } }

        it 'responds with an unprocessable entity status' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'does not update the roster' do
          expect { submit }.not_to(change { roster.reload.attributes })
        end
      end
    end
  end

  describe 'DELETE /rosters/:id' do
    subject(:submit) { delete "/rosters/#{roster.id}" }

    let!(:roster) { create :roster }

    context 'when logged in as an admin for a different roster' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      it 'redirects to all rosters' do
        submit
        expect(response).to redirect_to(rosters_path)
      end

      it 'destroys the given roster' do
        submit
        expect(Roster.find_by(id: roster.id)).to be_nil
      end
    end
  end

  describe 'GET /rosters/:id/setup' do
    subject(:call) { get "/rosters/#{roster.id}/setup" }

    let!(:roster) { create :roster }

    context 'when logged in as an admin for a different roster' do
      let(:current_user) { create :user, memberships: [build(:membership, admin: true)] }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      let(:current_user) { create :user, memberships: [build(:membership, roster:, admin: true)] }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end
end

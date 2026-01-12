# frozen_string_literal: true

RSpec.describe 'Rosters' do
  describe 'GET /rosters' do
    subject(:call) { get '/rosters' }

    context 'when logged in as a normal user' do
      before { login_as create(:user) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /rosters/new' do
    subject(:call) { get '/rosters/new' }

    context 'when logged in as a normal user' do
      before { login_as create(:user) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

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
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

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

      before { login_as create(:user) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a roster admin' do
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

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

      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

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
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

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

  describe 'GET /rosters/assignments' do
    subject(:call) { get '/rosters/assignments' }

    let(:roster) { create :roster }

    context 'when not logged in' do
      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as a user' do
      let(:roster) { create :roster }

      before { login_as create(:user, rosters: [roster]) }

      it 'redirects to the primary roster of the user' do
        call
        expect(response).to redirect_to(roster_assignments_path(roster))
      end
    end
  end

  describe 'GET /rosters/:id/setup' do
    subject(:call) { get "/rosters/#{roster.id}/setup" }

    let!(:roster) { create :roster }

    context 'when logged in as an admin for a different roster' do
      before { login_as create(:user, memberships: [build(:membership, admin: true)]) }

      it 'responds with a forbidden status' do
        call
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as an admin for the given roster' do
      before { login_as create(:user, memberships: [build(:membership, roster:, admin: true)]) }

      it 'responds successfully' do
        call
        expect(response).to be_successful
      end
    end
  end

  describe 'JSON #index' do
    subject(:json) do
      when_current_user_is :anyone
      get "/rosters/#{roster.to_param}.json"
      response.parsed_body
    end

    let(:roster) { create :roster }

    it 'contains roster attributes' do
      expect(json['name']).to eq(roster.name)
    end

    context 'when no one is on-call' do
      it 'has a null on_call value' do
        expect(json['on_call']).to be_nil
      end
    end

    context 'when the fallback user is on-call' do
      let(:fallback) { create :user, last_name: "O'Hanraha-hanrahan" }
      let(:roster) { create :roster, fallback_user: fallback }

      it 'lists the fallback user as on-call' do
        expect(json['on_call']['last_name']).to eq(fallback.last_name)
      end

      it 'does not list an end date' do
        expect(json['on_call']['until']).to be_nil
      end
    end

    context 'when someone is on-call' do
      let(:user) { create :user, last_name: 'Kanasis', rosters: [roster] }

      let! :assignment do
        create :assignment, start_date: Date.yesterday, end_date: Date.tomorrow, roster:, user:
      end

      it 'lists the on-call user' do
        expect(json['on_call']['last_name']).to eq(user.last_name)
      end

      it 'lists an end date and time' do
        expect(Time.zone.parse(json['on_call']['until'])).to eq(assignment.effective_end_datetime)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe RostersController do
  describe 'POST #create' do
    subject :submit do
      post :create, params: { roster: { name: 'Operations', switchover_time: '00:00' } }
    end

    context 'when the current user is an admin' do
      let(:admin) { roster_admin }

      before { when_current_user_is admin }

      context 'without errors' do
        it 'creates a roster' do
          expect { submit }.to change(Roster, :count).by 1
        end

        it 'redirects to the index' do
          submit
          expect(response).to redirect_to rosters_url
        end

        it 'puts a message in the flash' do
          submit
          expect(flash[:message]).not_to be_empty
        end

        it 'adds the current user to the roster as an admin' do
          submit
          expect(admin).to be_admin_in(Roster.last)
        end
      end

      context 'with errors' do
        subject :submit do
          post :create, params: { roster: { name: roster.name } }
        end

        let!(:roster) { create :roster, name: 'unique' }

        it 'does not create roster' do
          expect { submit }.not_to change(Roster, :count)
        end

        it 'gives errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'returns to the new template' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    context 'when the current user is not an admin' do
      before { when_current_user_is :whoever }

      it 'renders a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end

      it 'does not create a roster' do
        expect { submit }.not_to change(Roster, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    subject :submit do
      delete :destroy, params: { id: roster.id }
    end

    let(:roster) { create :roster }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'deletes the correct roster' do
        submit
        expect(Roster.where(id: roster.id)).to be_empty
      end

      it 'puts a message in the flash' do
        submit
        expect(flash[:message]).not_to be_empty
      end

      it 'redirects to the index' do
        submit
        expect(response).to redirect_to rosters_url
      end
    end

    context 'when the current user is not an admin in the roster' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #edit' do
    subject :submit do
      get :edit, params: { id: roster.id }
    end

    let(:roster) { create :roster }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'finds the correct roster' do
        submit
        expect(assigns.fetch(:roster)).to eq roster
      end

      it 'populates a users variable of all users of the roster' do
        user1 = roster_user roster
        user2 = roster_user roster
        user3 = roster_user roster
        submit
        expect(assigns.fetch(:roster).users).to include user1, user2, user3
      end

      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end

    context 'when the current user is not an admin in the roster' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #index' do
    subject(:submit) { get :index }

    context 'when the current user is an admin' do
      before { when_current_user_is roster_admin }

      it 'populates a rosters variable with all available rosters' do
        submit
        expect(assigns.fetch(:rosters)).to eq Roster.all
      end

      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
    end

    context 'when the current user is not an admin' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #new' do
    subject(:submit) { get :new }

    context 'when the current user is an admin' do
      before { when_current_user_is roster_admin }

      it 'renders the new template' do
        expect(submit).to render_template :new
      end
    end

    context 'when the current user is not an admin' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #update' do
    subject :submit do
      post :update, params: { id: roster.id, roster: attributes }
    end

    let(:roster) { create :roster }
    let(:user) { create :user }
    let(:attributes) { { name: 'unique', fallback_user_id: user.id, switchover_time: '00:00' } }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      context 'without errors' do
        it 'updates the roster name' do
          submit
          expect(roster.reload.name).to eql 'unique'
        end

        it 'updates the roster fallback user' do
          submit
          expect(roster.reload.fallback_user).to eql user
        end

        it 'redirects to the index' do
          submit
          expect(response).to redirect_to rosters_url
        end
      end

      context 'with errors' do
        let(:another_roster) { create :roster, name: 'not-unique' }

        before do
          attributes[:name] = another_roster.name
        end

        it 'does not update' do
          submit
          expect(roster.reload.fallback_user).not_to eql user
        end

        it 'includes errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'stays on the edit page' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    context 'when the current user is not an admin in the roster' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

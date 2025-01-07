# frozen_string_literal: true

RSpec.describe UsersController do
  let(:roster) { create :roster }

  describe 'POST #create' do
    let(:attributes) { attributes_for :user }

    let :submit do
      attributes[:roster_ids] << roster.id
      post :create, params: { user: attributes, roster_id: roster.id }
    end

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      context 'without errors' do
        it 'creates a user' do
          expect { submit }
            .to change(User, :count)
            .by 1
        end

        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_path(roster)
        end
      end

      context 'with errors' do
        before { attributes[:phone] = 'not a valid phone number' }

        it 'does not create a user' do
          expect { submit }.not_to change(User, :count)
        end

        it 'gives errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'renders new' do
          expect(submit).to render_template 'new'
        end
      end
    end

    context 'when the current user is an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
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

  describe 'DELETE #destroy' do
    subject :submit do
      delete :destroy, params: { id: user.id, roster_id: roster.id }
    end

    let(:user) { roster_user(roster) }

    before { when_current_user_is :whoever }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'finds the correct user' do
        submit
        expect(assigns.fetch(:user)).to eql user
      end

      context 'with no existing assignments' do
        it 'destroys the user' do
          allow(User).to receive(:find).and_return(user)
          allow(user).to receive(:destroy).and_return(true)
          submit
          expect(user).to have_received(:destroy)
        end

        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_path
        end
      end

      context 'with existing assignments' do
        before { create :assignment, user:, roster: }

        it 'redirects back' do
          submit
          expect(response).to redirect_to roster_users_path
        end
      end
    end

    context 'when the current user is an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
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

  describe 'GET #edit' do
    subject :submit do
      get :edit, params: { id: user.id, roster_id: roster.id }
    end

    let(:user) { create :user }

    before { when_current_user_is :whoever }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'finds the correct user' do
        submit
        expect(assigns.fetch(:user)).to eql user
      end

      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end

    context 'when the current user is editing themself' do
      before { when_current_user_is user }

      it 'finds the correct user' do
        submit
        expect(assigns.fetch(:user)).to eql user
      end

      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end

    context 'when the current user is not an admin nor editing themself' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #index' do
    subject :submit do
      get :index, params: { roster_id: roster.id }
    end

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'populates a users variable of all users' do
        users = Array.new(3) { roster_user(roster) }
        submit
        expect(assigns.fetch(:users)).to include(*users)
      end

      it 'populates a fallback variable with the roster fallback user' do
        user = roster_user roster
        roster.update(fallback_user: user)
        submit
        expect(assigns.fetch(:fallback)).to eql user
      end

      it 'renders the index template' do
        submit
        expect(response).to render_template :index
      end
    end

    context 'when the current user is an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
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
    subject :submit do
      get :new, params: { roster_id: roster.id }
    end

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'renders the new template' do
        submit
        expect(response).to render_template :new
      end
    end

    context 'when the current user is an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
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

  describe 'POST #transfer' do
    subject :submit do
      post :transfer, params: { id: user.id, roster_id: roster.id }
    end

    let(:user) { create :user }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      context 'with a succesfully added user' do
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_path(roster)
        end

        it 'shows a nice message' do
          submit
          expect(flash[:message]).to be_present
        end
      end

      context 'with a user somehow not added succesfully' do
        before do
          allow(User).to receive(:find).and_return(user)
          allow(user).to receive(:save).and_return(false)
        end

        it 'redirects back' do
          submit
          expect(response).to redirect_to roster_users_path(roster)
        end

        it 'shows errors' do
          submit
          expect(flash[:errors]).not_to be_nil
        end
      end
    end

    context 'when the current user is an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
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
      post :update, params: { id: user.id, user: changes, roster_id: roster.id }
    end

    let(:new_roster) { create :roster }
    let(:user) { roster_user(new_roster) }
    let(:changes) { { phone: '+14135451451', roster_ids: [roster.id, new_roster.id] } }

    context 'when the current user is an admin in the roster' do
      before { when_current_user_is roster_admin(roster) }

      context 'without errors' do
        it "updates the user's attributes" do
          submit
          expect(user.reload.phone).to eql changes[:phone]
        end

        it "updates the user's rosters" do
          submit
          expect(user.rosters).to include new_roster
        end

        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_path(roster)
        end

        it 'allows changing admin status in roster' do
          changes[:membership] = { admin: true }
          submit
          expect(user).to be_admin_in roster
        end
      end

      context 'with errors' do
        before { changes[:phone] = 'not a valid phone number' }

        it 'does not update the user' do
          expect { submit }.not_to(change { user.reload.phone })
        end

        it 'shows errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'renders edit' do
          expect(submit).to render_template 'edit'
        end
      end
    end

    context 'when the current user is editing themself' do
      before { when_current_user_is user }

      context 'without errors' do
        it "updates the user's attributes" do
          submit
          expect(user.reload.phone).to eql changes[:phone]
        end

        it "updates the user's rosters" do
          submit
          expect(user.rosters).to include new_roster
        end

        it 'redirects to the assignments page' do
          submit
          expect(response).to redirect_to roster_assignments_path(roster)
        end

        it 'does not allow changing admin status in roster' do
          changes[:membership] = { admin: true }
          submit
          expect(user).not_to be_admin_in roster
        end
      end

      context 'with errors' do
        before { changes[:phone] = 'not a valid phone number' }

        it 'does not update the user' do
          expect { submit }.not_to(change { user.reload.phone })
        end

        it 'shows errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'renders edit' do
          expect(submit).to render_template 'edit'
        end
      end

      context 'when the current user is the only roster admin and remiving their adminship' do
        let(:user) { roster_admin(roster) }

        before do
          when_current_user_is user
          changes[:membership] = { admin: false }
        end

        it 'does not change their adminhood' do
          expect { submit }.not_to(change { user.membership_in roster })
        end

        it 'renders edit' do
          expect(submit).to render_template 'edit'
        end

        it 'shows errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end
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
end

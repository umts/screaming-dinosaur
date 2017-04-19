require 'rails_helper'

describe UsersController do
  before :each do
    @roster = create :roster
  end

  describe 'POST #create' do
    before :each do
      @attributes = attributes_for(:user).except(:rosters)
      when_current_user_is :whoever
    end
    let :submit do
      post :create, user: @attributes, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      context 'without errors' do
        it 'creates a user' do
          expect { submit }
            .to change { User.count }
            .by 1
        end
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_url
        end
      end
      context 'with errors' do
        before :each do
          # invalid phone
          @attributes[:phone] = 'not a valid phone number'
        end
        it 'does not create a user, gives errors, and redirects back' do
          expect { submit }.to redirect_back
          expect { submit }
            .not_to change { User.count }
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
    context 'admin, not in roster' do
      before(:each) { when_current_user_is roster_admin }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @user = roster_user(@roster)
      when_current_user_is :whoever
    end
    let :submit do
      delete :destroy, id: @user.id, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'finds the correct user' do
        submit
        expect(assigns.fetch :user).to eql @user
      end
      context 'no existing assignments' do
        it 'destroys the user' do
          expect_any_instance_of(User)
            .to receive(:destroy)
            .and_return true
          submit
        end
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_url
        end
      end
      context 'with existing assignments' do
        before(:each) { create :assignment, user: @user, roster: @roster }
        it 'redirects back and shows errors' do
          expect { submit }.to redirect_back
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
    context 'admin, not in roster' do
      before(:each) { when_current_user_is roster_admin }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @user = create :user
      when_current_user_is :whoever
    end
    let :submit do
      get :edit, id: @user.id, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'finds the correct user' do
        submit
        expect(assigns.fetch :user).to eql @user
      end
      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end
    context 'self' do
      before(:each) { when_current_user_is @user }
      it 'finds the correct user' do
        submit
        expect(assigns.fetch :user).to eql @user
      end
      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end
    context 'not admin or self' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #index' do
    let :submit do
      get :index, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'populates a users variable of all users' do
        user_1 = roster_user @roster
        user_2 = roster_user @roster
        user_3 = roster_user @roster
        submit
        expect(assigns.fetch :users).to include user_1, user_2, user_3
      end
      it 'populates a fallback variable with the roster fallback user' do
        user = roster_user @roster
        Roster.where.not(id: @roster.id).delete_all
        expect_any_instance_of(Roster).to receive(:fallback_user).and_return(user)
        submit
        expect(assigns.fetch :fallback).to eql user
      end
      it 'renders the index template' do
        submit
        expect(response).to render_template :index
      end
    end
    context 'admin, not in roster' do
      before(:each) { when_current_user_is roster_admin }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #new' do
    let :submit do
      get :new, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'renders the new template' do
        submit
        expect(response).to render_template :new
      end
    end
    context 'admin, not in roster' do
      before(:each) { when_current_user_is roster_admin }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #transfer' do
    let(:user) { create :user }
    let :submit do
      post :transfer, id: user.id, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      context 'user added succesfullly' do
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_path(@roster)
        end
        it 'shows a nice message' do
          submit
          expect(flash[:message]).to be_present
        end
      end
      context 'user somehow not added succesfully' do
        before :each do
          expect_any_instance_of(User)
            .to receive(:save)
            .and_return false
        end
        it 'redirects back and shows errors' do
          expect { submit }.to redirect_back
          expect(flash[:errors]).not_to be_nil
        end
      end
    end
    context 'admin, not in roster' do
      before(:each) { when_current_user_is roster_admin }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #update' do
    before :each do
      @new_roster = create :roster
      @user = roster_user @roster
      @changes = { phone: '+14135451451', rosters: [@new_roster.id] }
    end
    let :submit do
      post :update, id: @user.id, user: @changes, roster_id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      context 'without errors' do
        it 'updates the user' do
          submit
          expect(@user.reload.phone).to eql @changes[:phone]
          expect(@user.rosters.take).to eql @new_roster
        end
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_url
        end
      end
      context 'with errors' do
        before :each do
          # incorrect phone
          @changes[:phone] = 'not a valid phone number'
        end
        it 'does not update the user, shows errors, and redirects back' do
          expect { submit }.to redirect_back
          expect { submit }
            .not_to change { @user.reload.phone }
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
    context 'self' do
      before(:each) { when_current_user_is @user }
      context 'without errors' do
        it 'updates the user' do
          submit
          expect(@user.reload.phone).to eql @changes[:phone]
          expect(@user.rosters.take).to eql @new_roster
        end
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to roster_users_url
        end
      end
      context 'with errors' do
        before :each do
          # incorrect phone
          @changes[:phone] = 'not a valid phone number'
        end
        it 'does not update the user, shows errors, and redirects back' do
          expect { submit }.to redirect_back
          expect { submit }
            .not_to change { @user.reload.phone }
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is :whoever }
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

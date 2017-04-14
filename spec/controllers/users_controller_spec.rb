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

  describe 'DELETE #destroy' do
    before :each do
      @user = create :user
      when_current_user_is :whoever
    end
    let :submit do
      delete :destroy, id: @user.id, roster_id: @roster.id
    end
    it 'finds the correct user' do
      submit
      expect(assigns.fetch :user).to eql @user
    end
    it 'destroys the user' do
      expect_any_instance_of(User)
        .to receive :destroy
      submit
    end
    it 'redirects to the index' do
      submit
      expect(response).to redirect_to roster_users_url
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
    it 'finds the correct user' do
      submit
      expect(assigns.fetch :user).to eql @user
    end
    it 'renders the edit template' do
      submit
      expect(response).to render_template :edit
    end
  end

  describe 'GET #index' do
    let :submit do
      when_current_user_is :whoever
      get :index, roster_id: @roster.id
    end
    it 'populates a users variable of all users' do
      user_1 = create :user, rosters: [@roster]
      user_2 = create :user, rosters: [@roster]
      user_3 = create :user, rosters: [@roster]
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'populates a fallback variable with the roster fallback user' do
      user = create :user, rosters: [@roster]
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

  describe 'GET #new' do
    let :submit do
      when_current_user_is :whoever
      get :new, roster_id: @roster.id
    end
    it 'renders the new template' do
      submit
      expect(response).to render_template :new
    end
  end

  describe 'POST #update' do
    before :each do
      @new_roster = create :roster
      @user = create :user, rosters: [@roster]
      @changes = { phone: '+14135451451', rosters: [@new_roster.id] }
      when_current_user_is :whoever
    end
    let :submit do
      post :update, id: @user.id, user: @changes, roster_id: @roster.id
    end
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
end

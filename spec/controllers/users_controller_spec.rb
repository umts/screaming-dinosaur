require 'rails_helper'

describe UsersController do
  describe 'POST #create' do
    before :each do
      @attributes = attributes_for :user
      when_current_user_is :whoever
    end
    let :submit do
      post :create, user: @attributes
    end
    context 'without errors' do
      it 'creates a user' do
        expect { submit }
          .to change { User.count }
          .by 1
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to users_url
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
      delete :destroy, id: @user.id
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
      expect(response).to redirect_to users_url
    end
  end

  describe 'GET #edit' do
    before :each do
      @user = create :user
      when_current_user_is :whoever
    end
    let :submit do
      get :edit, id: @user.id
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
      get :index
    end
    it 'populates a users variable of all users' do
      user_1 = create :user
      user_2 = create :user
      user_3 = create :user
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'populates no_fallback as true if there is no fallback user' do
      expect(User).to receive(:fallback).and_return nil
      submit
      expect(assigns.fetch :no_fallback).to be true
    end
    it 'populates no_fallback as false if there is a fallback user' do
      expect(User).to receive(:fallback).and_return "anything that isn't nil"
      submit
      expect(assigns.fetch :no_fallback).to be false
    end
    it 'renders the index template' do
      submit
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    let :submit do
      when_current_user_is :whoever
      get :new
    end
    it 'renders the new template' do
      submit
      expect(response).to render_template :new
    end
  end

  describe 'POST #update' do
    before :each do
      @user = create :user
      @changes = { phone: '+14135451451' }
      when_current_user_is :whoever
    end
    let :submit do
      post :update, id: @user.id, user: @changes
    end
    context 'without errors' do
      it 'updates the user' do
        submit
        expect(@user.reload.phone).to eql @changes[:phone]
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to users_url
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

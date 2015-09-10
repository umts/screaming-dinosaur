require 'rails_helper'

describe AssignmentsController do
  describe 'POST #create' do
    before :each do
      user = create :user
      @attributes = {
        start_date: Date.today,
        end_date: Date.tomorrow,
        user_id: user.id
      }
    end
    let :submit do
      post :create, assignment: @attributes
    end
    context 'without errors' do
      it 'creates an assignment based on the attributes'
      it 'redirects to the index'
    end
    context 'with errors' do
      it 'does not create an assignment'
      it 'gives some errors in the flash'
      it 'redirects back'
    end
  end

  describe 'GET #edit' do
    before :each do
      @assignment = create :assignment
    end
    let :submit do
      get :edit, id: @assignment.id
    end
    it 'populates a users variable of all users'
    it 'renders the edit template'
  end

  describe 'GET #index' do
    let :submit do
      get :index
    end
    context 'user_id in session' do
      before :each do
        @user = create :user
        when_current_user_is @user
      end
      it 'assigns the correct current user' do
        submit
        expect(assigns.fetch :current_user).to eql @user
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
    end
    context 'fcIdNumber in request' do
      before :each do
        @user = create :user
        request.env['fcIdNumber'] = @user.spire
      end
      it 'assigns the correct current user' do
        submit
        expect(assigns.fetch :current_user).to eql @user
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET #new' do
    before :each do
      @date = Date.today
    end
    let :submit do
      get :new, date: @date
    end
    it 'passes the date parameter through as a start_date variable'
    it 'populates an end_date instance variable 6 days after start_date'
    it 'populates a users variable containing all the users'
    it 'renders the new template'
  end

  describe 'POST #update' do
    before :each do
      @assignment = create :assignment
      user = create :user
      @changes = { user_id: user.id }
    end
    let :submit do
      post :update, id: @assignment.id, assignment: @changes
    end
    context 'without errors' do
      it 'updates the assignment'
      it 'redirects to the index'
    end
    context 'with errors' do
      it 'does not update the assignment'
      it 'includes errors in the flash'
      it 'redirects back'
    end
  end
end

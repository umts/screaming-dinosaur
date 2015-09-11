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
      when_current_user_is user
    end
    let :submit do
      post :create, assignment: @attributes
    end
    context 'without errors' do
      it 'creates an assignment' do
        submit
        expect(Assignment.count).to eql 1
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to assignments_url
      end
    end
    context 'with errors' do
      before :each do
        # Guaranteed to not be a user with this ID,
        # but will pass param validation in the controller.
        @attributes[:user_id] = User.pluck(:id).sort.last + 1
        # Need an HTTP_REFERER for it to redirect back
        @back = 'http://test.host/redirect'
        request.env['HTTP_REFERER'] = @back
      end
      it 'does not create an assignment' do
        submit
        expect(Assignment.count).to eql 0
      end
      it 'gives some errors in the flash' do
        submit
        expect(flash[:errors]).not_to be_empty
      end
      it 'redirects back' do
        submit
        expect(response).to redirect_to @back
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @assignment = create :assignment
      when_current_user_is :whoever
    end
    let :submit do
      delete :destroy, id: @assignment.id
    end
    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch :assignment).to eql @assignment
    end
    it 'destroys the assignment' do
      expect_any_instance_of(Assignment)
        .to receive :destroy
      submit
    end
    it 'redirects to the index' do
      submit
      expect(response).to redirect_to assignments_url
    end
  end

  describe 'GET #edit' do
    before :each do
      @assignment = create :assignment
      when_current_user_is :whoever
    end
    let :submit do
      get :edit, id: @assignment.id
    end
    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch :assignment).to eql @assignment
    end
    it 'populates a users variable of all users' do
      user_1 = create :user
      user_2 = create :user
      user_3 = create :user
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'renders the edit template' do
      submit
      expect(response).to render_template :edit
    end
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
      it 'populates an assignments variable of upcoming assignments' do
        old_assignment = create :assignment, user: @user,
                                             start_date: 1.month.ago.to_date,
                                             end_date: 3.weeks.ago.to_date
        new_assignment = create :assignment, user: @user,
                                             start_date: 1.month.since.to_date,
                                             end_date: 5.weeks.since.to_date
        submit
        expect(assigns.fetch :assignments).to include new_assignment
        expect(assigns.fetch :assignments).not_to include old_assignment
      end
      it 'populates a current_assignment variable of Assignment.current' do
        assignment = create :assignment
        expect(Assignment).to receive(:current).and_return assignment
        submit
        expect(assigns.fetch :current_assignment).to eql assignment
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
      context 'date given' do
        before :each do
          @date = Date.today
        end
        it 'sets the date variable to the sunday prior to the date given' do
          get :index, date: @date
          expect(assigns.fetch :date).to eql @date.beginning_of_week(:sunday)
        end
        it 'sets the week variable to the week starting with date variable' do
          get :index, date: @date
          sunday = assigns.fetch :date
          expect(assigns.fetch :week).to eql sunday..(sunday + 6.days)
        end
      end
      context 'no date given' do
        it 'sets the date variable to the sunday prior to today' do
          submit
          expect(assigns.fetch :date)
            .to eql Date.today.beginning_of_week(:sunday)
        end
        it 'sets the week variable to the week starting with date variable' do
          submit
          sunday = assigns.fetch :date
          expect(assigns.fetch :week).to eql sunday..(sunday + 6.days)
        end
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
      when_current_user_is :whoever
    end
    let :submit do
      get :new, date: @date
    end
    it 'passes the date parameter through as a start_date variable' do
      submit
      expect(assigns.fetch :start_date).to eql @date
    end
    it 'populates an end_date instance variable 6 days after start_date' do
      submit
      expect(assigns.fetch :end_date).to eql(@date + 6.days)
    end
    it 'populates a users variable containing all the users' do
      user_1 = create :user
      user_2 = create :user
      user_3 = create :user
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'renders the new template' do
      submit
      expect(response).to render_template :new
    end
  end

  describe 'POST #update' do
    before :each do
      @assignment = create :assignment
      @user = create :user
      @changes = { user_id: @user.id }
      when_current_user_is :whoever
    end
    let :submit do
      post :update, id: @assignment.id, assignment: @changes
    end
    context 'without errors' do
      it 'updates the assignment' do
        submit
        expect(@assignment.reload.user).to eql @user
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to assignments_url
      end
    end
    context 'with errors' do
      before :each do
        # Guaranteed to not be a user with this ID,
        # but will pass param validation in the controller.
        @changes[:user_id] = User.pluck(:id).sort.last + 1
        # Need an HTTP_REFERER for it to redirect back
        @back = 'http://test.host/redirect'
        request.env['HTTP_REFERER'] = @back
      end
      it 'does not update the assignment' do
        expect { submit }.not_to change { @assignment.reload.user }
      end
      it 'includes errors in the flash' do
        submit
        expect(flash[:errors]).not_to be_empty
      end
      it 'redirects back' do
        submit
        expect(response).to redirect_to @back
      end
    end
  end
end

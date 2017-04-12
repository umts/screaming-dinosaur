require 'rails_helper'

describe RotationsController do
  before :each do
    @rotation = create :rotation
  end
  describe 'POST #create' do
    before :each do
      user = create :user, rotations: [@rotation]
      @attributes = {
        start_date: Date.today,
        end_date: Date.tomorrow,
        user_id: user.id,
        rotation_id: @rotation.id
      }
      when_current_user_is user
    end
    let :submit do
      post :create, rotation_id: @rotation, assignment: @attributes
    end
    context 'without errors' do
      it 'creates an assignment' do
        submit
        expect(Assignment.count).to be 1
      end
      it 'redirects to the index with a date of the assignment start date' do
        submit
        expect(response).to redirect_to(
          rotation_assignments_url(date: @attributes[:start_date])
        )
      end
    end
    context 'with errors' do
      before :each do
        # Guaranteed to not be a user with this ID,
        # but will pass param validation in the controller.
        @attributes[:user_id] = User.pluck(:id).sort.last + 1
      end
      it 'does not create assignment, gives errors, and redirects back' do
        expect { submit }.to redirect_back
        expect(Assignment.all).to be_empty
        expect(flash[:errors]).not_to be_empty
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @assignment = create :assignment
      when_current_user_is :whoever
    end
    let :submit do
      delete :destroy, rotation_id: @assignment.rotation.id, id: @assignment.id
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
      expect(response).to redirect_to rotation_assignments_url
    end
  end

  describe 'GET #edit' do
    before :each do
      @assignment = create :assignment
      @rotation = create :rotation
      when_current_user_is :whoever
    end
    let :submit do
      get :edit, rotation_id: @rotation.id, id: @assignment.id
    end
    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch :assignment).to eql @assignment
    end
    it 'populates a users variable of all users' do
      user_1 = create :user, rotations: [@rotation] 
      user_2 = create :user, rotations: [@rotation]
      user_3 = create :user, rotations: [@rotation]
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'renders the edit template' do
      submit
      expect(response).to render_template :edit
    end
  end

  describe 'POST #generate_rotation' do
    before :each do
      @rotation = create :rotation
      @start_date = Date.today.strftime '%Y-%m-%d'
      @end_date = Date.tomorrow.strftime '%Y-%m-%d'
      user_1 = create :user, rotations: [@rotation]
      user_2 = create :user, rotations: [@rotation]
      user_3 = create :user, rotations: [@rotation]
      @user_ids = [user_1.id.to_s, user_2.id.to_s, user_3.id.to_s]
      @starting_user_id = @user_ids[1]
      when_current_user_is :whoever
    end
    let :submit do
      post :generate_rotation,
           rotation_id: @rotation.id,
           start_date: @start_date,
           end_date: @end_date,
           user_ids: @user_ids,
           starting_user_id: @starting_user_id
    end
    it 'calls Assignment#generate rotation with the given arguments' do
      # remove all other instances of rotation so 'any instance' definitely
      # refers to our @rotation instance
      Rotation.where.not(id: @rotation.id).delete_all
      expect_any_instance_of(Rotation).to receive(:generate_assignments)
        .with(@user_ids, Date.today, Date.tomorrow, @starting_user_id)
      submit
    end
    it 'has a flash message' do
      submit
      expect(flash[:message]).not_to be_empty
    end
    it 'redirects to the calendar with the start date given' do
      submit
      expect(response).to redirect_to rotation_assignments_path(date: Date.today)
    end
  end

  describe 'GET #index' do
    let :submit do
      get :index, rotation_id: @rotation.id
    end
    context 'user_id in session' do
      before :each do
        @user = create :user, rotations: [@rotation]
        when_current_user_is @user
      end
      it 'assigns the correct current user' do
        submit
        expect(assigns.fetch :current_user).to eql @user
      end
      it 'populates an assignments variable of upcoming assignments' do
        old_assignment = create :assignment, user: @user,
                                             rotation: @rotation,
                                             start_date: 1.month.ago.to_date,
                                             end_date: 3.weeks.ago.to_date
        new_assignment = create :assignment, user: @user,
                                             rotation: @rotation,
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
      it 'includes the switchover hour as a variable' do
        expect(CONFIG).to receive(:[]).with(:switchover_hour).and_return 12
        submit
        expect(assigns.fetch :switchover_hour).to be 12
      end
      it 'includes a variable of the fallback user' do
        fallback = create :user
        @rotation.update_attributes(fallback_user_id: fallback.id)
        submit
        expect(assigns.fetch :fallback_user).to eql fallback
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
      context 'date given' do
        it 'sets the month date variable to the 1st day of that month' do
          date = 5.months.ago
          get :index, date: date
          expect(assigns.fetch :month_date)
            .to eql date.beginning_of_month.to_date
        end
      end
      context 'no date given' do
        it 'sets the month date variable to the 1st day of current month' do
          submit
          expect(assigns.fetch :month_date).to eql Date.today.beginning_of_month
        end
      end
    end
    context 'fcIdNumber in request' do
      context 'user exists' do
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
      context 'user does not exist' do
        it 'redirects to unauthenticated sessions path' do
          request.env['fcIdNumber'] = '00000000@umass.edu'
          submit
          expect(response).to redirect_to unauthenticated_session_path
        end
      end
    end
  end

  describe 'GET #new' do
    before :each do
      @date = Date.today
      when_current_user_is :whoever
    end
    let :submit do
      get :new, rotation_id: @rotation.id, date: @date
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
      user_1 = create :user, rotations: [@rotation]
      user_2 = create :user, rotations: [@rotation]
      user_3 = create :user, rotations: [@rotation]
      submit
      expect(assigns.fetch :users).to include user_1, user_2, user_3
    end
    it 'renders the new template' do
      submit
      expect(response).to render_template :new
    end
  end

  describe 'GET #rotation_generator' do
    before :each do
      when_current_user_is :whoever
    end
    let :submit do
      get :rotation_generator, rotation_id: @rotation.id
    end
    it 'sets the users instance variable' do
      expect(User).to receive(:order).with(:last_name)
        .and_return 'whatever'
      submit
      expect(assigns.fetch :users).to eql 'whatever'
    end
    it 'sets the start date instance variable' do
      expect(Assignment).to receive(:next_rotation_start_date)
        .and_return 'whatever'
      submit
      expect(assigns.fetch :start_date).to eql 'whatever'
    end
    it 'renders the rotation_generator template' do
      submit
      expect(response).to render_template :rotation_generator
    end
  end

  describe 'POST #update' do
    before :each do
      @assignment = create :assignment
      @user = create :user, rotations: [@assignment.rotation]
      @changes = { user_id: @user.id }
      when_current_user_is :whoever
    end
    let :submit do
      post :update,
        id: @assignment.id,
        assignment: @changes,
        rotation_id: @assignment.rotation.id
    end
    context 'without errors' do
      it 'updates the assignment' do
        submit
        expect(@assignment.reload.user).to eql @user
      end
      it 'redirects to the index with a date of the assignment start date' do
        submit
        expect(response).to redirect_to(
          rotation_assignments_url(date: @assignment.start_date)
        )
      end
    end
    context 'with errors' do
      before :each do
        # Guaranteed to not be a user with this ID,
        # but will pass param validation in the controller.
        @changes[:user_id] = User.pluck(:id).sort.last + 1
      end
      it 'does not update, includes errors, and redirects back' do
        expect { submit }.to redirect_back
        expect(flash[:errors]).not_to be_empty
        expect(@assignment.reload.user).not_to eql @user
      end
    end
  end
end

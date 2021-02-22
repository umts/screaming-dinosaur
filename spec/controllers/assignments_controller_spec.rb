# frozen_string_literal: true

RSpec.describe AssignmentsController do
  before :each do
    @roster = create :roster
  end

  describe 'POST #create' do
    before :each do
      @user = roster_user @roster
      @attributes = {
        start_date: Date.today,
        end_date: Date.tomorrow,
        user_id: @user.id,
        roster_id: @roster.id
      }
    end
    let :submit do
      post :create, params: { roster_id: @roster, assignment: @attributes }
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      context 'without errors' do
        it 'creates an assignment' do
          submit
          expect(Assignment.count).to be 1
        end
        it 'sends an email to the new owner of the assignment' do
          expect_any_instance_of(Assignment).to receive(:notify)
          submit
        end
      end
      context 'with errors' do
        before :each do
          # Guaranteed to not be a user with this ID,
          # but will pass param validation in the controller.
          @attributes[:user_id] = User.pluck(:id).max + 1
        end
        it 'does not create assignment, gives errors, and redirects back' do
          expect { submit }.to redirect_back
          expect(Assignment.all).to be_empty
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
    context 'not admin' do
      before(:each) { when_current_user_is @user }
      context 'creating assignment belonging to self' do
        it 'creates the assignment' do
          expect { submit }.to change(Assignment, :count).by 1
        end
      end
      context 'creating assignment not belonging to self' do
        before(:each) { @attributes[:user_id] = @user.id + 1 }
        it 'does not create the assignment and explains why' do
          expect do
            expect { submit }.to redirect_back
          end.not_to change(Assignment, :count)
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @assignment = create :assignment
      when_current_user_is :whoever
    end
    let :submit do
      delete :destroy,
             params: { roster_id: @assignment.roster.id, id: @assignment.id }
    end
    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch :assignment).to eql @assignment
    end
    it 'destroys the assignment' do
      expect_any_instance_of(Assignment).to receive :destroy
      submit
    end
    it 'sends a notification to the owner of the assignment' do
      expect_any_instance_of(Assignment).to receive :notify
      submit
    end
  end

  describe 'GET #edit' do
    before :each do
      @assignment = create :assignment
      @roster = create :roster
      when_current_user_is :whoever
    end
    let :submit do
      get :edit, params: { roster_id: @roster.id, id: @assignment.id }
    end
    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch :assignment).to eql @assignment
    end
    it 'populates a users variable of all users' do
      user1 = roster_user @roster
      user2 = roster_user @roster
      user3 = roster_user @roster
      submit
      expect(assigns.fetch :users).to include user1, user2, user3
    end
    it 'renders the edit template' do
      submit
      expect(response).to render_template :edit
    end
  end

  describe 'POST #generate_rotation' do
    before :each do
      @start_date = Date.today.strftime '%Y-%m-%d'
      @end_date = Date.tomorrow.strftime '%Y-%m-%d'
      user1 = roster_user @roster
      user2 = roster_user @roster
      user3 = roster_user @roster
      @user_ids = [user1.id.to_s, user2.id.to_s, user3.id.to_s]
      @starting_user_id = @user_ids[1]
      when_current_user_is :whoever
      # To test the mailer method called on the returned assignments
      @assignments = [create(:assignment)]
    end
    let :submit do
      post :generate_rotation,
           params: {
             roster_id: @roster.id,
             start_date: @start_date,
             end_date: @end_date,
             user_ids: @user_ids,
             starting_user_id: @starting_user_id
           }
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'calls Assignment#generate rotation with the given arguments' do
        # remove all other instances of roster so 'any instance' definitely
        # refers to our @roster instance
        Roster.where.not(id: @roster.id).delete_all
        expect_any_instance_of(Roster).to receive(:generate_assignments)
          .with(@user_ids, Date.today, Date.tomorrow, @starting_user_id)
          .and_return @assignments
        expect_any_instance_of(Assignment).to receive :notify
        submit
      end
      it 'has a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end
      it 'redirects to the calendar with the start date given' do
        submit
        expect(response)
          .to redirect_to roster_assignments_path(date: Date.today)
      end
      context 'starting user not in selected users' do
        before(:each) { @starting_user_id = roster_user(@roster).id }
        it 'warns that the starting user is not in the selected users' do
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

  describe 'GET #index' do
    let :submit do
      get :index, params: { roster_id: @roster.id }
    end
    context 'user_id in session' do
      before :each do
        @user = roster_user @roster
        when_current_user_is @user
      end
      it 'assigns the correct current user' do
        submit
        expect(assigns.fetch :current_user).to eql @user
      end
      it 'populates an assignments variable of upcoming assignments' do
        old_assignment = create :assignment, user: @user,
                                             roster: @roster,
                                             start_date: 1.month.ago.to_date,
                                             end_date: 3.weeks.ago.to_date
        new_assignment = create :assignment, user: @user,
                                             roster: @roster,
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
        @roster.update(fallback_user_id: fallback.id)
        submit
        expect(assigns.fetch :fallback_user).to eql fallback
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
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
      get :new, params: { roster_id: @roster.id, date: @date }
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
      user1 = roster_user @roster
      user2 = roster_user @roster
      user3 = roster_user @roster
      submit
      expect(assigns.fetch :users).to include user1, user2, user3
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
      get :rotation_generator, params: { roster_id: @roster.id }
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'sets the users instance variable' do
        submit
        expect(assigns.fetch :users).to include(*@roster.users)
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
      @assignment = create :assignment
      @user = roster_user @assignment.roster
      @changes = { user_id: @user.id }
    end
    let :submit do
      post :update,
           params: {
             id: @assignment.id,
             assignment: @changes,
             roster_id: @assignment.roster.id
           }
    end
    context 'admin in roster' do
      before :each do
        @roster_admin = roster_admin @assignment.roster
        when_current_user_is @roster_admin
      end
      context 'without errors' do
        it 'updates the assignment' do
          submit
          expect(@assignment.reload.user).to eql @user
        end
        context 'owner is being changed' do
          it "notifies the new owner of the new assignment \
              and notifies the old owner of the deleted assignment" do
            expect_any_instance_of(Assignment).to receive(:notify)
              .with(:owner, of: :new_assignment, by: @roster_admin)
            expect_any_instance_of(Assignment).to receive(:notify)
              .with(@assignment.user, of: :deleted_assignment,
                                      by: @roster_admin)
            submit
          end
        end
        context 'owner is not being changed' do
          before(:each) { @changes[:user_id] = @assignment.user_id }
          it 'notifies the owner of the changed assignment' do
            expect_any_instance_of(Assignment).to receive(:notify)
              .with(:owner, of: :changed_assignment, by: @roster_admin)
            submit
          end
        end
      end
      context 'with errors' do
        before :each do
          # Guaranteed to not be a user with this ID,
          # but will pass param validation in the controller.
          @changes[:user_id] = User.pluck(:id).max + 1
        end
        it 'does not update, includes errors, and redirects back' do
          expect { submit }.to redirect_back
          expect(flash[:errors]).not_to be_empty
          expect(@assignment.reload.user).not_to eql @user
        end
      end
    end
    context 'self' do
      before(:each) { when_current_user_is @user }
      context 'updated assignment will belong to self' do
        it 'updates the assignment' do
          submit
          expect(@assignment.reload.user).to eql @user
        end
      end
      context 'updated assignment will not belong to self' do
        before(:each) { @changes[:user_id] = @user.id + 1 }
        it 'does not update the assignment and explains why' do
          expect { submit }.to redirect_back
          expect(@assignment.reload.user).not_to eql @user
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
  end
  describe 'GET #feed' do
    let(:roster) { create :roster }
    let(:user) { create :user, rosters: [roster] }
    context 'user has a valid access token' do
      let :submit do
        get :feed, params: { format: 'ics', token: user.calendar_access_token,
                             roster: roster.name }
      end
      it 'allows the request' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'is a calendar file' do
        submit
        expect(response.media_type).to eq('text/calendar')
      end
    end
    context 'user does not belong to roster' do
      let :submit do
        new_roster = create :roster
        get :feed, params: { format: 'ics', token: user.calendar_access_token,
                             roster: new_roster.name }
      end
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'not a valid access token' do
      let :submit do
        get :feed, params: { format: 'ics', token: SecureRandom.hex,
                             roster: roster.name }
      end
      it 'returns a 404' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end

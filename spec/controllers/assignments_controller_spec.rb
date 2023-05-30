# frozen_string_literal: true

RSpec.describe AssignmentsController do
  let(:roster) { create :roster }

  describe 'POST #create' do
    subject :submit do
      post :create, params: { roster_id: roster, assignment: attributes }
    end

    let(:user) { roster_user(roster) }
    let :attributes do
      { start_date: Time.zone.today,
        end_date: Date.tomorrow,
        user_id: user.id,
        roster_id: roster.id }
    end

    context 'when you are an admin in roster' do
      before { when_current_user_is roster_admin(roster) }

      context 'when there are no errors' do
        it 'creates an assignment' do
          submit
          expect(Assignment.count).to be 1
        end

        it 'sends an email to the new owner of the assignment' do
          assignment = build :assignment
          allow(Assignment).to receive(:new).and_return(assignment)
          allow(assignment).to receive(:notify)
          submit
          expect(assignment).to have_received(:notify)
        end
      end

      context 'when there are errors' do
        before do
          # Guaranteed to not be a user with this ID,
          # but will pass param validation in the controller.
          attributes[:user_id] = User.maximum(:id) + 1
        end

        it 'does not create assignment' do
          submit
          expect(Assignment.all).to be_empty
        end

        it 'gives errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'redirects back' do
          expect { submit }.to redirect_back
        end
      end
    end

    context 'when you are not admin' do
      before { when_current_user_is user }

      context 'when creating assignment belonging to self' do
        it 'creates the assignment' do
          expect { submit }.to change(Assignment, :count).by 1
        end
      end

      context 'when creating assignment not belonging to self' do
        before { attributes[:user_id] = user.id + 1 }

        it 'does not create the assignment' do
          expect { submit }.not_to change(Assignment, :count)
        end

        it 'gives errors' do
          expect { submit }.to redirect_back
        end

        it 'redirects back' do
          submit
          expect(flash[:errors]).not_to be_empty
        end
      end
    end
  end

  describe 'GET #edit' do
    subject :submit do
      get :edit, params: { roster_id: roster.id, id: assignment.id }
    end

    let(:assignment) { create :assignment }

    before do
      when_current_user_is :whoever
    end

    it 'finds the correct assignment' do
      submit
      expect(assigns.fetch(:assignment)).to eql assignment
    end

    it 'populates a users variable of all users' do
      user1 = roster_user roster
      user2 = roster_user roster
      user3 = roster_user roster
      submit
      expect(assigns.fetch(:users)).to include user1, user2, user3
    end

    it 'renders the edit template' do
      submit
      expect(response).to render_template :edit
    end
  end

  describe 'POST #generate_rotation' do
    subject :submit do
      post :generate_rotation,
           params: { roster_id: roster.id,
                     start_date: Time.zone.today.to_fs(:db),
                     end_date: Date.tomorrow.to_fs(:db),
                     user_ids: user_ids,
                     starting_user_id: starting_user_id }
    end

    let(:user_ids) { Array.new(3) { roster_user(roster).id.to_s } }
    let(:starting_user_id) { user_ids[1] }
    let(:assignment) { create :assignment }

    before do
      when_current_user_is :whoever
    end

    context 'when you are an admin in roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'calls Roster#generate_assignments with the given arguments' do
        allow(Roster).to receive(:find_by).and_return(roster)
        allow(roster).to receive(:generate_assignments).and_return []
        submit
        expect(roster).to have_received(:generate_assignments)
          .with(user_ids, Time.zone.today, Date.tomorrow, starting_user_id)
      end

      it 'notifies the new assignment holders' do
        allow(Roster).to receive(:find_by).and_return(roster)
        allow(roster).to receive(:generate_assignments).and_return [assignment]
        allow(assignment).to receive :notify
        submit
        expect(assignment).to have_received :notify
      end

      it 'has a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end

      it 'redirects to the calendar with the start date given' do
        submit
        expect(response)
          .to redirect_to roster_assignments_path(date: Time.zone.today)
      end

      context 'when the starting user is not in the selected users' do
        let(:starting_user_id) { roster_user(roster).id }

        it 'warns that the starting user is not in the selected users' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'redirects back' do
          expect { submit }.to redirect_back
        end
      end
    end

    context 'when you are an admin, but not in roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when you are not admin' do
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

    context 'with a user_id in session' do
      let(:user) { roster_user(roster) }
      let! :old_assignment do
        create :assignment,
               user: user,
               roster: roster,
               start_date: 1.month.ago.to_date,
               end_date: 3.weeks.ago.to_date
      end
      let! :new_assignment do
        create :assignment,
               user: user,
               roster: roster,
               start_date: 1.month.since.to_date,
               end_date: 5.weeks.since.to_date
      end

      before { when_current_user_is user }

      it 'assigns the correct current user' do
        submit
        expect(assigns.fetch(:current_user)).to eql user
      end

      it 'populates assignments including upcoming assignments' do
        submit
        expect(assigns.fetch(:assignments)).to include new_assignment
      end

      it 'populates assignments excluding upcoming assignments' do
        submit
        expect(assigns.fetch(:assignments)).not_to include old_assignment
      end

      it 'populates the current assignment' do
        assignment = create :assignment
        allow(Assignment).to receive(:current).and_return assignment
        submit
        expect(assigns.fetch(:current_assignment)).to eql assignment
      end

      it 'uses Assignment.current to populate the current assignment' do
        allow(Assignment).to receive(:current)
        submit
        expect(Assignment).to have_received(:current)
      end

      it 'includes a variable of the fallback user' do
        fallback = create :user
        roster.update(fallback_user_id: fallback.id)
        submit
        expect(assigns.fetch(:fallback_user)).to eql fallback
      end

      it 'renders the correct template' do
        submit
        expect(response).to render_template :index
      end
    end

    context 'with fcIdNumber in the request' do
      before { request.env['fcIdNumber'] = '00000000@umass.edu' }

      context 'when that user exists' do
        let(:user) { create :user }

        before { request.env['fcIdNumber'] = user.spire }

        it 'assigns the correct current user' do
          submit
          expect(assigns.fetch(:current_user)).to eql user
        end

        it 'renders the correct template' do
          submit
          expect(response).to render_template :index
        end
      end

      context 'when that user does not exist' do
        it 'redirects to unauthenticated sessions path' do
          submit
          expect(response).to redirect_to unauthenticated_session_path
        end
      end
    end
  end

  describe 'GET #new' do
    subject :submit do
      get :new, params: { roster_id: roster.id, date: date }
    end

    let(:date) { Time.zone.today }

    before { when_current_user_is :whoever }

    it 'passes the date parameter through as a start_date variable' do
      submit
      expect(assigns.fetch(:start_date)).to eql date
    end

    it 'populates an end_date instance variable 6 days after start_date' do
      submit
      expect(assigns.fetch(:end_date)).to eql(date + 6.days)
    end

    it 'populates a users variable containing all the users' do
      user1 = roster_user roster
      user2 = roster_user roster
      user3 = roster_user roster
      submit
      expect(assigns.fetch(:users)).to include user1, user2, user3
    end

    it 'renders the new template' do
      submit
      expect(response).to render_template :new
    end
  end

  describe 'GET #rotation_generator' do
    subject :submit do
      get :rotation_generator, params: { roster_id: roster.id }
    end

    context 'when you are an admin in roster' do
      before { when_current_user_is roster_admin(roster) }

      it 'sets the users instance variable' do
        submit
        expect(assigns.fetch(:users)).to include(*roster.users)
      end

      it 'uses the next rotation start date' do
        allow(Assignment).to receive(:next_rotation_start_date)
        submit
        expect(Assignment).to have_received(:next_rotation_start_date)
      end

      it 'sets the start date instance variable' do
        allow(Assignment).to receive(:next_rotation_start_date).and_return 'whatever'
        submit
        expect(assigns.fetch(:start_date)).to eql 'whatever'
      end

      it 'renders the rotation_generator template' do
        submit
        expect(response).to render_template :rotation_generator
      end
    end

    context 'when you are an admin, but not in the roster' do
      before { when_current_user_is roster_admin }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when you are not an admin' do
      before { when_current_user_is :whoever }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #update' do
    subject :submit do
      post :update, params: { id: assignment.id,
                              assignment: changes,
                              roster_id: assignment.roster.id }
    end

    let(:assignment) { create :assignment }
    let(:user) { roster_user(assignment.roster) }
    let(:changes) { { user_id: user.id } }

    context 'when you are an admin in the roster' do
      let(:admin) { roster_admin(assignment.roster) }

      before { when_current_user_is admin }

      it 'updates the assignment' do
        submit
        expect(assignment.reload.user).to eql user
      end

      context 'when the owner is being changed' do
        before do
          allow(Assignment).to receive(:includes).and_return(Assignment)
          allow(Assignment).to receive(:find).and_return(assignment)
          allow(assignment).to receive(:notify)
        end

        it 'notifies the owner of the new assignment' do
          submit
          expect(assignment).to have_received(:notify)
            .with(:owner, of: :new_assignment, by: admin)
        end

        it 'notifies the owner of the deleted assignment' do
          previous_user = assignment.user
          submit
          expect(assignment).to have_received(:notify)
            .with(previous_user, of: :deleted_assignment, by: admin)
        end
      end

      context 'when the owner is not being changed' do
        let(:changes) { { user_id: assignment.user_id } }

        before do
          allow(Assignment).to receive(:includes).and_return(Assignment)
          allow(Assignment).to receive(:find).and_return(assignment)
          allow(assignment).to receive(:notify)
        end

        it 'notifies the owner of the changed assignment' do
          submit
          expect(assignment).to have_received(:notify)
            .with(:owner, of: :changed_assignment, by: admin)
        end
      end

      context 'with errors' do
        let(:changes) { { user_id: User.maximum(:id) + 1 } }

        it 'does not update the assignment' do
          submit
          expect(assignment.reload.user).not_to eql user
        end

        it 'displays errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'redirects back' do
          expect { submit }.to redirect_back
        end
      end
    end

    context 'when you are updating your own assignment' do
      before { when_current_user_is user }

      context 'when the updated assignment will belong to you' do
        it 'updates the assignment' do
          submit
          expect(assignment.reload.user).to eql user
        end
      end

      context 'when the updated assignment will not belong to you' do
        let(:changes) { { user_id: user.id + 1 } }

        it 'does not update the assignment' do
          submit
          expect(assignment.reload.user).not_to eql user
        end

        it 'displays errors' do
          submit
          expect(flash[:errors]).not_to be_empty
        end

        it 'redirects back' do
          expect { submit }.to redirect_back
        end
      end
    end
  end

  describe 'GET #feed' do
    let(:roster) { create :roster }
    let(:user) { create :user, rosters: [roster] }

    context 'when the user has a valid access token' do
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

    context 'when the user does not belong to roster' do
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

    context 'when the user does not have a valid access token' do
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

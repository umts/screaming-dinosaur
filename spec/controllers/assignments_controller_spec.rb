# frozen_string_literal: true

RSpec.describe AssignmentsController do
  let(:roster) { create :roster }

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

  describe 'GET #index' do
    subject :submit do
      get :index, params: { roster_id: roster.id }
    end

    context 'with a user_id in session' do
      let(:user) { roster_user(roster) }
      let! :old_assignment do
        create :assignment, user:, roster:,
                            start_date: 1.month.ago.to_date, end_date: 3.weeks.ago.to_date
      end
      let! :new_assignment do
        create :assignment, user:, roster:,
                            start_date: 1.month.since.to_date, end_date: 5.weeks.since.to_date
      end

      before { when_current_user_is user }

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
      get :new, params: { roster_id: roster.id, date: }
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
          allow(Assignment).to receive_messages(includes: Assignment, find: assignment)
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
          allow(Assignment).to receive_messages(includes: Assignment, find: assignment)
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

        it 'stays on the edit page' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
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

        it 'redirects to the assignments page' do
          submit
          expect(response).to have_http_status(:unprocessable_content)
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

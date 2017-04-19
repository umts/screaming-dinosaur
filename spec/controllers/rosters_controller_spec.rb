require 'rails_helper'

describe RostersController do
  before :each do
    user = create :user
    when_current_user_is user
  end
  describe 'POST #create' do
    let :submit do
      post :create, roster: { name: 'Operations' }
    end
    context 'without errors' do
      it 'creates a roster' do
        expect { submit }.to change { Roster.count }.from(1).to(2)
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to rosters_url
      end
      it 'puts a message in the flash' do
        submit
        expect(flash[:message]).not_to be_empty
      end
    end
    context 'with errors' do
      before :each do
        @roster = create :roster, name: 'unique'
      end
      let :submit do
        post :create, roster: { name: @roster.name }
      end
      it 'does not create roster, gives errors, and redirects back' do
        expect { submit }.to redirect_back
        expect { submit }.not_to change { Roster.count }
        expect(flash[:errors]).not_to be_empty
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @roster = create :roster
    end
    let :submit do
      delete :destroy, id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'deletes the correct roster' do
        submit
        expect(Roster.where(id: @roster.id)).to be_empty
      end
      it 'destroys the roster' do
        expect_any_instance_of(Roster).to receive :destroy
        submit
      end
      it 'puts a message in the flash' do
        submit
        expect(flash[:message]).not_to be_empty
      end
      it 'redirects to the index' do
        submit
        expect(response).to redirect_to rosters_url
      end
    end
    context 'not admin in roster' do
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @roster = create :roster
    end
    let :submit do
      get :edit, id: @roster.id
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      it 'finds the correct roster' do
        submit
        expect(assigns.fetch :roster).to eql @roster
      end
      it 'populates a users variable of all users of the roster' do
        user_1 = roster_user @roster
        user_2 = roster_user @roster
        user_3 = roster_user @roster
        submit
        expect(assigns.fetch :users).to include user_1, user_2, user_3
      end
      it 'renders the edit template' do
        submit
        expect(response).to render_template :edit
      end
    end
    context 'not admin in roster' do
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #index' do
    let :submit do
      get :index
    end
    it 'populates a rosters variable with all available rosters' do
      submit
      expect(assigns.fetch :rosters).to eq Roster.all
    end
    it 'renders the correct template' do
      submit
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      expect(get :new).to render_template :new
    end
  end

  describe 'POST #update' do
    before :each do
      @roster = create :roster
      @user = create :user
      @attributes = { name: 'unique', fallback_user_id: @user.id }
    end
    let :submit do
      post :update, id: @roster.id, roster: @attributes
    end
    context 'admin in roster' do
      before(:each) { when_current_user_is roster_admin(@roster) }
      context 'without errors' do
        it 'updates the roster' do
          submit
          expect(@roster.reload.name).to eql 'unique'
          expect(@roster.reload.fallback_user).to eql @user
        end
        it 'redirects to the index' do
          submit
          expect(response).to redirect_to rosters_url
        end
      end
      context 'with errors' do
        before :each do
          @another_roster = create :roster, name: 'not-unique'
          @attributes[:name] = @another_roster.name
        end
        it 'does not update, includes errors, and redirects back' do
          expect { submit }.to redirect_back
          expect(flash[:errors]).not_to be_empty
          expect(@roster.reload.fallback_user).not_to eql @user
        end
      end
    end
    context 'not admin in roster' do
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

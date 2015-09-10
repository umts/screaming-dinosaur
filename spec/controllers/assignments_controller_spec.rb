require 'rails_helper'

describe AssignmentsController do
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
end

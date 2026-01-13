# frozen_string_literal: true

require 'paper_trail/frameworks/rspec'

RSpec.describe VersionsController do
  describe 'GET #undo', :versioning do
    let(:change_user) { create :user }
    let(:assignment) { create :assignment }
    let(:redirect_target) { '/redirect_to_me' }

    context 'when the change is made by user' do
      before do
        when_current_user_is change_user
        request.env['HTTP_REFERER'] = redirect_target
      end

      context 'when the version is a "create" version' do
        subject(:submit) { get :undo, params: { id: version.id } }

        let! :version do
          PaperTrail.request.whodunnit = change_user.id.to_s
          assignment.versions.last
        end

        it 'destroys the object' do
          submit
          expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'redirects' do
          submit
          expect(response).to redirect_to redirect_target
        end

        it 'informs you of success' do
          submit
          expect(flash[:message]).to eq 'Assignment has been deleted.'
        end
      end

      context 'when the version is a "destroy" version' do
        subject(:submit) { get :undo, params: { id: version.id } }

        let! :version do
          PaperTrail.request.whodunnit = change_user.id.to_s
          assignment.destroy
          assignment.versions.last
        end

        it 'brings the object back to life' do
          submit
          expect { assignment.reload }.not_to raise_error
        end

        it 'redirects' do
          submit
          expect(response).to redirect_to redirect_target
        end
      end

      context 'when the version is an "update" version' do
        subject(:submit) { get :undo, params: { id: version.id } }

        let!(:original_start_date) { assignment.start_date }
        let! :version do
          PaperTrail.request.whodunnit = change_user.id.to_s
          assignment.start_date -= 1.day
          assignment.save!
          assignment.versions.last
        end

        it 'undoes the change' do
          submit
          expect(assignment.reload.start_date).to eql original_start_date
        end

        it 'redirects' do
          submit
          expect(response).to redirect_to redirect_target
        end
      end
    end

    context 'when the change is not made by current user' do
      subject(:submit) { get :undo, params: { id: version.id } }

      before { when_current_user_is :whoever }

      let!(:version) { assignment.versions.last }

      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

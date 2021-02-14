# frozen_string_literal: true

require 'paper_trail/frameworks/rspec'

RSpec.describe ChangesController do
  describe 'GET #undo' do
    before :each do
      @change_user = create :user
      with_versioning do
        PaperTrail.request.whodunnit = @change_user.id.to_s
        @created, @updated, @destroyed = Array.new(3) { create :assignment }
        # CREATE
        @create_version = @created.versions.last
        # UPDATE
        @original_start_date = @updated.start_date
        @updated.start_date -= 1.day
        @updated.save!
        @update_version = @updated.versions.last
        # DESTROY
        @destroyed.destroy
        @destroy_version = @destroyed.versions.last
      end
    end
    let(:submit) { get :undo, params: { id: version.id } }
    context 'change made by user' do
      before(:each) { when_current_user_is @change_user }
      context 'create version' do
        let(:version) { @create_version }
        it 'destroys the object' do
          expect { submit }.to redirect_back
          expect { @created.reload }
            .to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:message]).to eql 'Assignment has been deleted.'
        end
      end
      context 'destroy version' do
        let(:version) { @destroy_version }
        it 'brings the object back to life' do
          expect { submit }.to redirect_back
          expect { @destroyed.reload }.not_to raise_error
        end
      end
      context 'update version' do
        let(:version) { @update_version }
        it 'undoes the change' do
          expect { submit }.to redirect_back
          expect(@updated.reload.start_date).to eql @original_start_date
        end
      end
    end
    context 'change not made by current user' do
      before(:each) { when_current_user_is :whoever }
      let(:version) { @update_version } # it doesn't matter
      it 'returns a 401' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

# frozen_string_literal: true

require 'paper_trail/frameworks/rspec'

RSpec.describe 'Versions' do
  describe 'POST /versions/:id/undo', :versioning do
    subject(:submit) { post "/versions/#{version.id}/undo", headers: }

    let(:headers) { {} }
    let(:current_user) { create :user }

    context 'when logged in as a user unrelated to the roster' do
      let(:version) { Current.set(user: create(:user)) { create(:assignment).versions.last } }

      it 'responds with a forbidden status' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in as the author of a version with no referer' do
      let(:version) { Current.set(user: current_user) { create(:assignment).versions.last } }

      it 'redirects to the root path' do
        submit
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when logged in as the author of a version with a referer' do
      let(:version) { Current.set(user: current_user) { create(:assignment).versions.last } }
      let(:headers) { { 'HTTP_REFERER' => '/some_path' } }

      it 'redirects to the referer' do
        submit
        expect(response).to redirect_to('/some_path')
      end
    end

    context 'when logged in as the author of a creation' do
      let(:version) { Current.set(user: current_user) { assignment.versions.last } }
      let(:assignment) { create :assignment }

      it 'destroys the record' do
        submit
        expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when logged in as the author of an update' do
      let(:version) do
        Current.set(user: current_user) do
          assignment.tap { |assignment| assignment.update!(start_date: 2.days.ago) }.versions.last
        end
      end
      let!(:assignment) { create :assignment, start_date: 1.day.ago }

      it 'reverts the record' do
        submit
        expect(assignment.reload).to have_attributes(start_date: 1.day.ago.to_date)
      end
    end

    context 'when logged in as the author of a deletion' do
      let(:version) { Current.set(user: current_user) { assignment.tap(&:destroy!).versions.last } }
      let!(:assignment) { create :assignment }

      it 'restores the record' do
        submit
        expect { assignment.reload }.not_to raise_error
      end
    end
  end
end

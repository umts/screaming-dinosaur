# frozen_string_literal: true

RSpec.describe 'Assignments' do
  describe 'GET /rosters/:id/assignments/generate_by_weekday' do
    subject(:call) { get "/rosters/#{roster.id}/assignments/generate_by_weekday" }

    let(:roster) { create :roster }
    let(:admin) { create :user }

    before do
      create :membership, roster: roster, user: admin, admin: true
      set_user admin
    end

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end
  end
end

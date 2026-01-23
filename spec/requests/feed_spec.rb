# frozen_string_literal: true

RSpec.describe 'Feeds' do
  describe 'GET /show' do
    it 'returns http success' do
      user = create :user
      roster = Roster.first
      get feed_path(roster: roster.name, token: user.calendar_access_token)
      # get '/feed/show'
      expect(response).to have_http_status(:success)
    end
  end
end

require 'rails_helper'

# Request specs don't include session data,
# equivalent to being unauthenticated.
describe 'Authentication' do
  context 'unauthenticated user' do
    it 'redirects to unauthenticated session path' do
      get '/assignments'
      expect(response).to redirect_to unauthenticated_session_path
    end
  end
end

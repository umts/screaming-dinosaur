require 'factory_girl_rails'
require 'simplecov'
require 'umts-custom-matchers'

SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop
end

RSpec.configure do |config|
  config.before :all do
    FactoryGirl.reload
  end
  config.include FactoryGirl::Syntax::Methods
  config.include UmtsCustomMatchers
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def when_current_user_is(user)
  session[:user_id] = case user
                      when User
                        user
                      when :whoever
                        create :user
                      end.id
end

def roster_user(roster)
  create :user, rosters: [roster]
end

def roster_admin(roster)
  create(:membership, roster: roster, admin: true).user
end

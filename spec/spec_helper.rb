# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/vendor/gems/'
  refuse_coverage_drop
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'rack_session_access/capybara'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods
  config.include UmtsCustomMatchers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before :all do
    FactoryBot.reload
  end

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome
  end
end

def when_current_user_is(user)
  current_user = case user
                 when User
                   user
                 when :whoever
                   create :user
                 else
                   raise ArgumentError
                 end
  if defined? page # Capybara
    page.set_rack_session user_id: current_user.id
  else # Request specs
    session[:user_id] = current_user.id
  end
end
alias set_current_user when_current_user_is

def roster_user(roster)
  create :user, rosters: [roster]
end

def roster_admin(roster = nil)
  if roster.present?
    create(:membership, roster: roster, admin: true).user
  else (create :membership, admin: true).user
  end
end

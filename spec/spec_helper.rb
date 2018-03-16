# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop
end

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rack_session_access/capybara'
require 'factory_girl_rails'
require 'umts-custom-matchers'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
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

def roster_admin(roster = nil)
  if roster.present?
    create(:membership, roster: roster, admin: true).user
  else (create :membership, admin: true).user
  end
end

# For feature testing
def set_current_user(user)
  page.set_rack_session user_id: user.id
end

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
require 'umts_custom_matchers'

ActiveRecord::Migration.maintain_test_schema!
Timecop.safe_mode = true
Capybara.server = :puma, { Silent: true }

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

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed

  config.before :all do
    FactoryBot.reload
  end

  config.before :each, type: :system do
    driven_by :rack_test
  end

  config.before :each, type: :system, js: true do
    driven_by :selenium, using: :headless_chrome
  end

  Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
end

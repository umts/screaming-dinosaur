# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  maximum_coverage_drop 0.5 if ENV['CI']
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'rspec/retry'
require 'rack_session_access/capybara'
require 'paper_trail/frameworks/rspec'

ActiveRecord::Migration.maintain_test_schema!
Capybara.server = :puma, { Silent: true }
Capybara.enable_aria_label = true

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods

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

  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.retry_callback = proc do |example|
    Capybara.reset! if example.metadata[:js]
  end

  config.order = :random
  Kernel.srand config.seed

  config.before :all do
    FactoryBot.reload
  end

  config.before :each, type: :system do
    driven_by :rack_test
  end

  config.before :each, :js, type: :system do
    driven_by :selenium, using: :headless_chrome
  end

  config.around :each, :js, type: :system do |example|
    example.run_with_retry retry: 3
  end

  Dir['./spec/support/**/*.rb'].each { |f| require f }
end

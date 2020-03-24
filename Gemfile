# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootstrap-sass', '~> 3.3'
# constrain coffee-rails until rails 6
gem 'coffee-rails', '<= 4.2.2'
gem 'factory_bot_rails'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mysql2'
gem 'paper_trail', '~> 9.2'
gem 'rails', '~> 5.1'
gem 'sassc-rails'
gem 'snappconfig'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '= 3.8.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'listen', '~> 3.0'
  gem 'rb-readline', require: false
end

group :development, :test do
  gem 'haml_lint'
  gem 'pry-byebug'
  gem 'puma', '~> 3.12'
  gem 'rubocop'
  gem 'umts-custom-cops'
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-matchers'
  gem 'webdrivers'
end

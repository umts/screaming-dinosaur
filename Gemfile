# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'cssbundling-rails'
gem 'csv'
gem 'friendly_id'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'importmap-rails'
gem 'irb'
gem 'jbuilder'
gem 'mysql2'
gem 'net-http'
# TODO: remove when we have modern glibc
gem 'nokogiri', force_ruby_platform: true
gem 'paper_trail'
gem 'phonelib'
gem 'propshaft'
gem 'rails', '~> 8.0.2'
gem 'terser'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519', require: false
  gem 'haml_lint', require: false
  gem 'listen'
  gem 'overcommit', require: false
  gem 'rb-readline', require: false
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development, :test do
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'puma'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rspec-retry'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'timecop'
end

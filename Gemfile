# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'friendly_id'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'jbuilder'
gem 'mysql2'
gem 'net-http'
gem 'paper_trail', '~> 12.3'
gem 'phonelib'
gem 'rails', '~> 7.0.8'
gem 'sassc-rails'
gem 'sprockets-rails'
gem 'terser'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-yarn', require: false
  gem 'ed25519', require: false
  gem 'haml_lint', require: false
  gem 'listen'
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
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'puma'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-matchers'
end

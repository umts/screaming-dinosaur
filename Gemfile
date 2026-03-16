# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'action_policy'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'csv'
gem 'friendly_id'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'irb'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'kaminari'
gem 'maintenance_tasks'
gem 'net-http'
# TODO: remove when we have modern glibc
gem 'nokogiri', force_ruby_platform: true
gem 'omniauth'
gem 'paper_trail'
gem 'phonelib'
gem 'propshaft'
gem 'puma'
gem 'rails', '~> 8.1.2'
gem 'stimulus-rails'
gem 'thruster', require: false
gem 'trilogy'

group :production do
  gem 'exception_notification'
  gem 'solid_queue'
end

group :production, :development do
  gem 'omniauth-entra-id'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'ed25519', require: false
  gem 'haml_lint', require: false
  gem 'kamal', require: false
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
  gem 'dotenv'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end

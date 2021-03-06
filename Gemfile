# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootstrap', '~> 4.2'
gem 'factory_bot_rails'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'jbuilder'
gem 'jquery-rails'
gem 'mysql2'
gem 'paper_trail', '~> 11.1'
gem 'rails', '~> 6.1.3'
gem 'sassc-rails'
gem 'snappconfig'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.14.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519', '>= 1.2', '< 2.0', require: false
  gem 'listen', '~> 3.0'
  gem 'rb-readline', require: false
end

group :development, :test do
  gem 'haml_lint'
  gem 'pry-byebug'
  gem 'puma'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-matchers'
  gem 'webdrivers'
end

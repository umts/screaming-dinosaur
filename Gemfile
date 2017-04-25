# frozen_string_literal: true
source 'https://rubygems.org'

gem 'coffee-rails'
gem 'factory_girl_rails'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mysql'
gem 'paper_trail'
gem 'rails', '~> 4.2'
gem 'sass-rails'
gem 'snappconfig'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'rb-readline', require: false
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'mocha'
  gem 'pry-byebug'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-cops'
  gem 'umts-custom-matchers'
  gem 'haml_lint'
end

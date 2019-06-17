# frozen_string_literal: true

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

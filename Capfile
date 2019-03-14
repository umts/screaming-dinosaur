# frozen_string_literal: true

%w[setup deploy scm/git pending bundler rails rails/console passenger]
  .each { |r| require "capistrano/#{r}" }
require 'whenever/capistrano'

install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

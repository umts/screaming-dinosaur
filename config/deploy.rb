# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '~> 3.14.1'

set :application, 'screaming_dinosaur'
set :repo_url, 'https://github.com/umts/screaming-dinosaur.git'
set :branch, :main
set :deploy_to, "/srv/#{fetch :application}"

set :log_level, :info

set :whenever_command, %i[sudo bundle exec whenever]

append :linked_files, 'config/database.yml'

append :linked_dirs, '.bundle', 'log'

set :passenger_restart_with_sudo, true

# frozen_string_literal: true

set :application, 'screaming_dinosaur'
set :repo_url, 'https://github.com/umts/screaming-dinosaur.git'
set :branch, :main
set :deploy_to, "/srv/#{fetch :application}"

set :log_level, :info

append :linked_files, 'config/credentials/production.key'

append :linked_dirs, '.bundle', 'log', 'storage'

set :passenger_restart_with_sudo, true
set :bundle_version, 4

before 'deploy:updated', 'bootsnap:precompile'
after 'deploy:published', 'solid_queue:restart'

# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'screaming_dinosaur'

set :scm, :git
set :repo_url, 'git@github.com:umts/screaming-dinosaur.git'
set :branch, :master

set :keep_releases, 5

set :deploy_to, "/srv/#{fetch :application}"

set :log_level, :info

set :whenever_command, [:sudo, :bundle, :exec, :whenever]

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/application.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log'
)

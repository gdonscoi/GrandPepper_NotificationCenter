# config valid only for current version of Capistrano
lock '3.2.1'

set :application, 'gcm'
set :repo_url, 'git@github.com:gdonscoi/GrandPepper_NotificationCenter.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "master"

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/grandpepper-assets/gcm/production"
set :tmp_dir, "/grandpepper-assets/gcm/tmp"
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('../config/secrets.rb')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# RVM - create grandpepper
set :rvm_type, :system
set :rvm_ruby_version, '2.1.5@pressit'
set :rvm_roles, [:app, :web]

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end


  after :publishing, :restart

end

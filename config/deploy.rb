
# Repository
set :repo_url,       "git://github.com/ontohub/ontohub.git"
set :branch,         "fix-capistrano"

set :application,    "ontohub"
set :deploy_to,      "/local/home/ontohub/webapp"
set :linked_dirs,    %w{ data log tmp/pids tmp/cache tmp/sockets public/assets }
set :bundle_without, "development deployment test"
set :rails_env,      "production"

# rbenv configuration stuff
set :rbenv_type, :user
set :rbenv_custom_path, "/local/usr/ruby"
set :rbenv_ruby, "2.1.6"
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

set :ssh_options,    user: 'ontohub'
set :log_level,      :info

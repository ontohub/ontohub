
# Repository
set :repo_url,       "git://github.com/ontohub/ontohub.git"
set :branch,         Settings.hostname

set :application,    "ontohub"
set :deploy_to,      "/srv/http/ontohub"
set :linked_dirs,    %w{ data log tmp/pids tmp/cache tmp/sockets public/assets }
set :bundle_without, "development deployment test"
set :rails_env,      "production"

set :ssh_options,    user: 'ontohub'
set :log_level,      :info

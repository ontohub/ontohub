set :stage, :production

server Settings.hostname, roles: %w{web app db}

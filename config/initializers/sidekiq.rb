
Sidekiq.configure_server do |config|
  config.redis = { namespace: 'ontohub' }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'ontohub' }
end

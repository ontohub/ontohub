
Sidekiq.configure_server do |config|
  config.redis = Ontohub::RedisConnection.new.pool.
    with_namespace("#{Settings.redis.namespace}:sidekiq")
end

Sidekiq.configure_client do |config|
  config.redis = Ontohub::RedisConnection.new.pool.
    with_namespace("#{Settings.redis.namespace}:sidekiq")
end

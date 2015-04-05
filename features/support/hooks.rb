Before do
  redis = WrappingRedis::RedisWrapper.new
  redis.del redis.keys if redis.keys.any?
  Sidekiq::Worker.clear_all
end

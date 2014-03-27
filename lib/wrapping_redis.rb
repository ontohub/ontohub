module WrappingRedis

  # gets and reuses the Sidekiq-redis connection
  def redis
    RedisWrapper.new
  end

  class RedisWrapper

    def method_missing(name, *args, &block)
      Sidekiq.redis { |redis| redis.send(name, *args, &block) }
    end

  end

end

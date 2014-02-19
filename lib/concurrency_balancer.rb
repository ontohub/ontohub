class ConcurrencyBalancer

  REDIS_KEY = "processing_iris"
  class AlreadyProcessingError < StandardError; end
  class UnmarkedProcessingError < StandardError; end

  def mark_as_processing_or_complain(iri, unlock_this_iri: nil)
    successful = redis.sadd REDIS_KEY, iri
    raise AlreadyProcessingError, iri unless successful
    mark_as_finished_processing(unlock_this_iri) if unlock_this_iri
  end

  def mark_as_finished_processing(iri)
    successful = redis.srem REDIS_KEY, iri
    raise UnmarkedProcessingError, iri unless successful
  end

  protected

  # gets and reuses the Sidekiq-redis connection
  def redis
    redis = Sidekiq.instance_variable_get(:@redis)
    if redis.nil?
      hash = Sidekiq.instance_variable_get(:@hash)
      redis = Sidekiq.instance_variable_set(:@redis, Sidekiq::RedisConnection.create(hash || {}))
    end
    redis
  end

end

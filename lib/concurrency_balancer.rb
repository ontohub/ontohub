class ConcurrencyBalancer

  REDIS_KEY = "processing_iris"
  SEQUENTIAL_LOCK_KEY = 'sequential_parse_locked'
  MAX_TRIES = 3
  class AlreadyProcessingError < StandardError; end
  class UnmarkedProcessingError < StandardError; end
  class AlreadyLockedError < StandardError; end

  def mark_as_processing_or_complain(iri, unlock_this_iri: nil)
    successful = redis.sadd REDIS_KEY, iri
    raise AlreadyProcessingError, "This iri <#{iri}> is already being processed" unless successful
    mark_as_finished_processing(unlock_this_iri) if unlock_this_iri
  end

  def mark_as_finished_processing(iri)
    successful = redis.srem REDIS_KEY, iri
    raise UnmarkedProcessingError, "This iri <#{iri}> should've being marked as done, but wasn't marked as processing beforehand" unless successful
  end

  def self.sequential_lock
    if RedisWrapper.new.sadd(SEQUENTIAL_LOCK_KEY, true)
      begin
        yield
      rescue Exception => e
        RedisWrapper.new.srem(SEQUENTIAL_LOCK_KEY, true)
        raise e
      end
    else
      raise AlreadyLockedError, 'the sequential lock is already set.'
    end
  end

  protected

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

class ConcurrencyBalancer
  include WrappingRedis

  REDIS_KEY = "processing_iris"
  SEQUENTIAL_LOCK_KEY = 'sequential_parse_locked'
  MAX_TRIES = 3

  class Error < ::StandardError; end
  class AlreadyProcessingError < Error; end
  class UnmarkedProcessingError < Error; end
  class AlreadyLockedError < Error; end

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

end

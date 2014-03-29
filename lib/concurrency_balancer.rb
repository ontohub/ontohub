# This is a helper used in the import of ontologies.
# It uses redis to create an atomic global store
# for the currently processing ontologies (by their iris).
# This allows to lock on concurrency problems in the
# way that a job can only parse an ontology (and write content)
# if no other job currently parses this ontology.
class ConcurrencyBalancer
  include WrappingRedis

  REDIS_KEY = "processing_iris"
  SEQUENTIAL_LOCK_KEY = 'sequential_parse_locked'
  MAX_TRIES = 3

  class Error < ::StandardError; end
  class AlreadyProcessingError < Error; end
  class UnmarkedProcessingError < Error; end
  class AlreadyLockedError < Error; end

  # Marks an ontology (by its iri) as processing.
  # As one ontology parsing job can contain multiple
  # ontologies this is needed to circumvent
  # concurrency problems
  def mark_as_processing_or_complain(iri, unlock_this_iri: nil)
    successful = redis.sadd REDIS_KEY, iri
    raise AlreadyProcessingError, "This iri <#{iri}> is already being processed" unless successful
    mark_as_finished_processing(unlock_this_iri) if unlock_this_iri
  end

  # This marks an ontology (by its iri) as
  # done (in the scope of processing ontology-content
  def mark_as_finished_processing(iri)
    successful = redis.srem REDIS_KEY, iri
    raise UnmarkedProcessingError, "This iri <#{iri}> should've being marked as done, but wasn't marked as processing beforehand" unless successful
  end

  # Basic sequential lock which ensures that only one
  # (concurrently executed job) can be really executed
  # at the same time (used as part of the sequential queue).
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

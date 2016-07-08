module Hets
  # - Meta component
  # This is the base class of the Node Evaluator It should not be used
  # directly but instead be subclassed. This is necessary since we usually
  # want to register specific callbacks.  See Hets::DG::NodeEvaluator for the
  # actual evaluator.
  class ConcurrentEvaluator < BaseEvaluator
    class Error < ::StandardError; end
    class AlreadyEvaluatingError < Error; end

    CHECK_MUTEX_KEY_PREFIX = "#{self}-evaluating_check:".freeze
    CHECK_MUTEX_EXPIRATION = 10.seconds

    EVALUATION_MUTEX_KEY_PREFIX = "#{self}:evaluating:".freeze
    EVALUATION_MUTEX_EXPIRATION = HetsInstance::FORCE_FREE_WAITING_PERIOD

    delegate :semaphore_stack, to: :importer
    delegate :ontologies_count, to: :importer

    def process(node_type, order, *args)
      super(node_type, order, *args)
    rescue Exception
      cancel_concurrency_handling_on_error
      raise
    end

    protected
    # As concurrency handling is usually performed across
    # multiple method calls during the parsing-chain,
    # we will need to initialize and finish concurrency
    # handling manually. A block-approach is just not
    # feasible.
    def initiate_concurrency_handling(lock_key)
      key = evaluation_key(lock_key)
      semaphore = Semaphore.new(key, expiration: EVALUATION_MUTEX_EXPIRATION)
      Semaphore.exclusively(check_key(lock_key),
                            expiration: CHECK_MUTEX_EXPIRATION) do
        raise AlreadyEvaluatingError if Semaphore.locked?(key)
        semaphore.lock
      end
      semaphore_stack.last.try(:unlock)
      semaphore_stack << semaphore
    end

    def finish_concurrency_handling
      semaphore_stack.last.unlock
    end

    def cancel_concurrency_handling_on_error
      semaphore_stack.reverse_each(&:unlock)
    end

    def check_key(lock_key)
      "#{CHECK_MUTEX_KEY_PREFIX}#{lock_key}"
    end

    def evaluation_key(lock_key)
      "#{EVALUATION_MUTEX_KEY_PREFIX}#{lock_key}"
    end
  end
end

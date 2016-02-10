module Hets
  # - Meta component
  # This is the base class of the Node Evaluator It should not be used
  # directly but instead be subclassed. This is necessary since we usually
  # want to register specific callbacks.  See Hets::DG::NodeEvaluator for the
  # actual evaluator.
  class ConcurrentEvaluator < BaseEvaluator
    delegate :semaphore_stack, to: :importer
    delegate :ontologies_count, to: :importer

    def process(node_type, order, *args)
      super(node_type, order, *args)
    rescue Exception => e
      cancel_concurrency_handling_on_error
      raise e
    end

    protected
    # As concurrency handling is usually performed across
    # multiple method calls during the parsing-chain,
    # we will need to initialize and finish concurrency
    # handling manually. A block-approach is just not
    # feasible.
    def initiate_concurrency_handling(lock_key)
      semaphore = Semaphore.new(lock_key)
      semaphore.lock
      semaphore_stack.last.try(:unlock)
      semaphore_stack << semaphore
    end

    def finish_concurrency_handling
      semaphore_stack.last.unlock
    end

    def cancel_concurrency_handling_on_error
      semaphore_stack.reverse_each(&:unlock)
    end
  end
end

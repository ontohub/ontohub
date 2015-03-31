module Hets
  # - Meta component
  # This is the base class of the Node Evaluator It should not be used
  # directly but instead be subclassed. This is necessary since we usually
  # want to register specific callbacks.  See Hets::DG::NodeEvaluator for the
  # actual evaluator.
  class ConcurrentEvaluator < BaseEvaluator
    concurrency_delegates = [
      :concurrency, :dgnode_stack,
      :dgnode_stack_id, :next_dgnode_stack_id,
    ]
    delegate *concurrency_delegates, to: :hets_evaluator
    delegate :ontologies_count, to: :hets_evaluator

    protected
    # As concurrency handling is usually performed across
    # multiple method calls during the parsing-chain,
    # we will need to initialize and finish concurrency
    # handling manually. A block-approach is just not
    # feasible.
    def initiate_concurrency_handling(ontohub_iri)
      concurrency.mark_as_processing_or_complain(ontohub_iri,
        unlock_this_iri: dgnode_stack[dgnode_stack_id])
      dgnode_stack << ontohub_iri
    end

    def finish_concurrency_handling
      all_dgnodes_parsed = next_dgnode_stack_id == hets_evaluator.dgnode_count
      concurrency.mark_as_finished_processing(dgnode_stack.last) if all_dgnodes_parsed
    end

    def cancel_concurrency_handling_on_error
      dgnode_stack.reverse_each do |dgnode|
        concurrency.unmark_as_processing_on_error(dgnode)
      end
    end

  end
end

module Hets

  # - Meta component
  # This is the base class of the Node Evaluator It should not be used
  # directly but instead be subclassed. This is necessary since we usually
  # want to register specific callbacks.  See Hets::NodeEvaluator for the
  # actual evaluator.
  class BaseNodeEvaluator
    attr_accessor :hets_evaluator
    attr_accessor :ontology
    attr_accessor :logic_callback

    concurrency_delegates = [
      :concurrency, :dgnode_stack,
      :dgnode_stack_id, :next_dgnode_stack_id,
    ]
    delegate *concurrency_delegates, to: :hets_evaluator
    delegate :user, to: :hets_evaluator
    delegate :ontologies_count, to: :hets_evaluator

    # - Meta method
    # registers a callback-method for a specific node (with node meaning a
    # denominator for an element which occurs in the Hets DGXML output)
    #   - The (node_type, order) pair is the signature
    #     of a registration. Multiple callback methods can
    #     be registered for one signature.
    #   - to: is the symbol-designator of the method.
    def self.register(node_type, order, to: nil)
      ensure_registrations
      @registrations[[node_type, order]] ||= []
      @registrations[[node_type, order]].push(to)
    end

    def self.ensure_registrations
      @registrations ||= {}
    end

    def initialize(hets_evaluator)
      self.hets_evaluator = hets_evaluator
    end

    def parent_ontology
      hets_evaluator.ontology
    end

    # - Meta method
    # This is the main method that is being called during the
    # parsing process. It decides which actual method will
    # be called in order to process the parse step. This may
    # be a no-op.
    # If there is a registered method which corresponds to
    # the signature (node_type, order) this will be called.
    # Otherwise it falls back to the default naming schema of
    # 'nodetype_order' as method name. This default method
    # will only be called if it is defined, thus resulting
    # in a no-op as fallback.
    def process(node_type, order, *args)
      if registered?(node_type, order)
        registered_methods(node_type, order).each do |method_name|
          self.send(method_name, *args)
        end
      else
        default_method_name = :"#{node_type}_#{order}"
        self.send(default_method_name, *args) if respond_to?(default_method_name)
      end
    rescue Exception => e
      cancel_concurrency_handling_on_error
      raise e
    end

    private
    def registered?(node_type, order, method_name=nil)
      selected_registrations = registered_methods(node_type, order)
      if method_name
        query = selected_registrations.include?(method_name.to_sym)
      else
        query = selected_registrations.any?
      end
      selected_registrations && query
    end

    def registered_methods(node_type, order)
      registrations = self.class.instance_variable_get(:@registrations)
      selected_registrations = registrations[[node_type, order]] || []
    end

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

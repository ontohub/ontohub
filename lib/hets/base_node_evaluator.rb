module Hets
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

    def process(node_type, order, *args)
      if registered?(node_type, order)
        registered_methods(node_type, order).each do |method_name|
          self.send(method_name, *args)
        end
      else
        default_method_name = :"#{node_type}_#{order}"
        self.send(default_method_name, *args) if respond_to?(default_method_name)
      end
    end

    def code_reference_for(ontology_name)
      code_doc = hets_evaluator.code_document
      return if code_doc.nil?
      elements = code_doc.xpath("//*[contains(@name, '##{ontology_name}')]")
      code_range = elements.first.try(:attr, "range")
      code_reference_from_range(code_range)
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


    def code_reference_from_range(range)
      return if range.nil?
      match = range.match( %r{
        (?<begin_line>\d+)\.
        (?<begin_column>\d+)
        -
        (?<end_line>\d+)\.
        (?<end_column>\d+)}x)
      if match
        reference = CodeReference.new(begin_line: match[:begin_line].to_i,
          begin_column: match[:begin_column].to_i,
          end_line: match[:end_line].to_i,
          end_column: match[:end_column].to_i)
      end
    end

    def initiate_concurrency_handling(ontohub_iri)
      concurrency.mark_as_processing_or_complain(ontohub_iri,
        unlock_this_iri: dgnode_stack[dgnode_stack_id])
      dgnode_stack << ontohub_iri
    end

    def finish_concurrency_handling
      all_dgnodes_parsed = next_dgnode_stack_id == hets_evaluator.dgnode_count
      concurrency.mark_as_finished_processing(dgnode_stack.last) if all_dgnodes_parsed
    end

  end
end

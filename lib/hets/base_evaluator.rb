module Hets

  # - Meta component
  # This is the base class of the Hets Evaluators It should not be used
  # directly but instead be subclassed. This is necessary since we usually
  # want to register specific callbacks. See Hets::*::*Evaluator for the
  # actual evaluators.
  class BaseEvaluator
    attr_accessor :importer
    attr_accessor :ontology
    attr_accessor :logic_callback

    delegate :user, to: :importer

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

    def initialize(importer)
      self.importer = importer
    end

    def parent_ontology
      importer.ontology
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
    end

    protected
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
  end
end

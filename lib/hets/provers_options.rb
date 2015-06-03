module Hets
  class ProversOptions < HetsOptions
    protected

    def prepare
      super
      prepare_node
    end

    def prepare_node
      ontology = @options[:ontology]
      if ontology.is_a?(Ontology)
        @options[:node] = ontology.name if ontology.in_distributed?
        @options.delete(:ontology)
      end
    end
  end
end

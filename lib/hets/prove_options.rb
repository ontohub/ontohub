module Hets
  class ProveOptions < HetsOptions
    protected

    def prepare
      super
      prepare_node
      prepare_prover
      prepare_axioms
      prepare_theorems
    end

    def prepare_node
      ontology = @options[:ontology]
      if ontology.is_a?(Ontology)
        @options[:node] = ontology.name if ontology.in_distributed?
        @options.delete(:ontology)
      end
    end

    def prepare_prover
      if @options[:prover].is_a?(Prover)
        @options[:prover] = @options[:prover].name
      end
    end

    def prepare_axioms
      prepare_sentences(:axioms)
    end

    def prepare_theorems
      prepare_sentences(:theorems)
    end

    def prepare_sentences(field)
      if @options[field].is_a?(Array)
        @options[field].map! do |sentence_or_name|
          if sentence_or_name.is_a?(Sentence)
            sentence_or_name.name
          else
            # This is already a prepared string (sentence name).
            sentence_or_name
          end
        end
      end
    end
  end
end

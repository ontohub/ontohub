module Hets
  class ProveOptions < HetsOptions
    def initialize(opts = {})
      @need_to_normalize_timeout = opts.has_key?(:timeout)
      super(opts)
    end

    def add(**opts)
      @need_to_normalize_timeout = opts.has_key?(:timeout)
      super(**opts)
    end

    protected

    def prepare
      super
      prepare_node
      prepare_prover
      prepare_timeout
      prepare_axioms
      prepare_theorems
    end

    def prepare_node
      @ontology = @options[:ontology]
      if @ontology.is_a?(Ontology)
        @options[:node] = @ontology.name if @ontology.in_distributed?
        @options.delete(:ontology)
      end
    end

    def prepare_prover
      if @options[:prover].is_a?(Prover)
        @options[:prover] = @options[:prover].name
      end
    end

    def prepare_timeout
      normalize_timeout
      if @options[:timeout].is_a?(Fixnum)
        @options[:timeout] = @options[:timeout].to_s
      end
    end

    def prepare_axioms
      prepare_sentences(:axioms)
    end

    def prepare_theorems
      prepare_sentences(:theorems)
    end

    def prepare_sentences(field)
      if @options[field].respond_to?(:map)
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

    # Hets considers the given timeout as "timeout per goal"
    # Ontohub considers the selected timeout as "overall timeout"
    # This should be normalized once after setting the timeout.
    def normalize_timeout
      if @need_to_normalize_timeout
        if @options[:timeout]
          # Hets can only handle integers as the timeout.
          @options[:timeout] = [1, @options[:timeout].to_i / goals_count].max
        end
        @need_to_normalize_timeout = false
      end
    end

    def goals_count
      if @options[:theorems]
        @options[:theorems].size
      elsif @ontology && @ontology.in_distributed?
        @ontology.theorems.count
      else
        1
      end
    end
  end
end

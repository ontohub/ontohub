module ParsingCallback

  class GenericCallback

    attr_reader :ontology

    def initialize(ontology)
      @ontology = ontology
    end

    # Callbacks to be executed after an object has been created
    #
    def ontology(hash, ontology)
    end

    def ontology_end(hash, ontology)
    end

    def symbol(hash, symbol)
    end

    def axiom(hash, axiom)
    end

    def link(hash, link)
    end

    # Callbacks to be executed only with the hash
    # returns a boolean value to decide, whether the
    # original callback should "go on"
    #
    def pre_symbol(hash)
      true
    end

    def pre_axiom(hash)
      true
    end

    def pre_link(hash)
      true
    end

  end

end

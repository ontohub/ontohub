module ParsingCallback

  class GenericCallback

    attr_reader :ontology

    def initialize(ontology)
      @ontology = ontology
    end

    # Callbacks to be executed after an object has been created
    #
    def ontology(_hash, _ontology)
    end

    def ontology_end(_hash, _ontology)
    end

    def symbol(_hash, _symbol)
    end

    def axiom(_hash, _axiom)
    end

    def theorem(_hash, _theorem)
    end

    def mapping(_hash, _mapping)
    end

    # Callbacks to be executed only with the hash
    # returns a boolean value to decide, whether the
    # original callback should "go on"
    #
    def pre_symbol(_hash)
      true
    end

    def pre_axiom(_hash)
      true
    end

    def pre_theorem(_hash)
      true
    end

    def pre_mapping(_hash)
      true
    end

  end

end

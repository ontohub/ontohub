module ParsingCallback

  class GenericCallback

    attr_reader :ontology

    def initialize(ontology)
      @ontology = ontology
    end

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

  end

end

module ParsingCallback::OWL

  IDENTIFIERS = %w(OWL OWL2)

  def self.defined_for?(logic_name)
    IDENTIFIERS.include?(logic_name)
  end

  class Callback < ParsingCallback::GenericCallback

    def axiom(hash, axiom)
    end

  end

end

module ParsingCallback::OWL

  IDENTIFIERS = %w(OWL OWL2)

  def self.defined_for?(logic_name)
    IDENTIFIERS.include?(logic_name)
  end

  class Callback < ParsingCallback::GenericCallback

    def axiom(hash, axiom)
    end

    private
    def is_annotation_sentence?(axiom_hash)
      axiom_hash['symbol_hashes'].each do |hash|
        return true if hash['kind'] == 'AnnotationProperty'
      end
      false
    end

  end

end

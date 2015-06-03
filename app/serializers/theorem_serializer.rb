class TheoremSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      qualified_locid_for(object)
    end
  end

  attributes :iri,
             :name,
             :definition,
             :evaluation_state
  has_one :proof_status, serializer: ProofStatusSerializer::Reference
  has_one :ontology, serializer: OntologySerializer::Reference

  attributes :symbols,
             :proof_attempts

  def iri
    Reference.new(object).iri
  end

  def definition
    object.text
  end

  def evaluation_state
    object.state
  end

  def symbols
    qualified_locid_for(object, :symbols)
  end

  def proof_attempts
    qualified_locid_for(object, :proof_attempts)
  end
end

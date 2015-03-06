class SentenceSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      qualified_locid_for(object)
    end
  end

  attributes :iri, :symbols
  attributes :name, :text, :imported

  has_one :ontology, serializer: OntologySerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def symbols
    qualified_locid_for(object, :symbols)
  end
end

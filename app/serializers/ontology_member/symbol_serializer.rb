class OntologyMember::SymbolSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      qualified_locid_for(object)
    end
  end

  attributes :iri, :sentences
  attributes :name, :text, :kind, :label, :comment

  has_one :ontology, serializer: OntologySerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def sentences
    qualified_locid_for(object, :sentences)
  end
end

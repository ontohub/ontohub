class MappingSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      qualified_locid_for(object)
    end
  end

  attributes :iri
  attributes :name, :kind, :theorem, :proven, :local

  has_one :ontology, serializer: OntologySerializer::Reference
  has_one :source_ontology, serializer: OntologySerializer::Reference
  has_one :target_ontology, serializer: OntologySerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def source_ontology
    object.source
  end

  def target_ontology
    object.target
  end
end

class OntologyMember::SymbolSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      url_for(object)
    end
  end

  attributes :iri, :sentences
  attributes :name, :definition, :kind, :label, :comment

  has_one :ontology, serializer: OntologySerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def definition
    object.text
  end

  def sentences
    url_for([object, :sentences])
  end
end

class OntologyVersionSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :number

    def iri
      url_for(object)
    end
  end

  attributes :iri, :evaluation_state

  attributes :number, :commit_oid
  attributes :basepath, :file_extension

  has_one :ontology, serializer: OntologySerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def evaluation_state
    object.state
  end
end

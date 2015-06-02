class OntologyTypeSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      urls.ontology_type_url(object,
                             host: Ontohub::Application.config.fqdn,
                             port: Ontohub::Application.config.port)
    end
  end

  attributes :iri, :documentation_url
  attributes :name, :description

  def iri
    Reference.new(object).iri
  end

  def documentation_url
    object.documentation
  end
end

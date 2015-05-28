class LogicSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      urls.logic_url(object,
                     host: Ontohub::Application.config.fqdn,
                     port: Ontohub::Application.config.port)
    end
  end

  attributes :iri, :name, :description
  attributes :standardization_status, :defined_by

  def iri
    Reference.new(object).iri
  end
end

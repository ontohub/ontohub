class LicenseModelSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      urls.license_model_url(object,
                             host: Ontohub::Application.config.fqdn,
                             port: Ontohub::Application.config.port)
    end
  end

  attributes :iri
  attributes :name, :description, :url

  def iri
    Reference.new(object).iri
  end
end

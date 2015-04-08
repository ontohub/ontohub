class FormalityLevelSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      urls.license_model_url(object, host: Ontohub::Application.config.fqdn)
    end
  end

  attributes :iri
  attributes :name, :description

  def iri
    Reference.new(object).iri
  end
end

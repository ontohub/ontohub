class RepositorySerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      urls.repository_url(object,
                          host: Ontohub::Application.config.fqdn,
                          port: Ontohub::Application.config.port)
    end
  end

  attributes :iri, :remote_origin, :source
  attributes :name, :path, :description

  def iri
    Reference.new(object).iri
  end

  def remote_origin
    object.mirror? || object.fork?
  end

  def source
    if remote_origin
      {
        type: object.remote_type,
        source_type: object.source_type,
        state: object.state,
        address: object.source_address
      }
    end
  end
end

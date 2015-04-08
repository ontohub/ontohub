class ApplicationSerializer < ActiveModel::Serializer
  def urls
    Rails.application.routes.url_helpers
  end

  def qualified_locid_for(resource, *commands, **query_components)
    iri = "#{Ontohub::Application.config.fqdn}#{resource.locid}"
    iri << "///#{commands.join('///')}" if commands.any?
    iri << "?#{query_components.to_query}" if query_components.any?
    iri
  end
end

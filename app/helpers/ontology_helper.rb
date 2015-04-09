module OntologyHelper

  def current_version
    o = @ontology.parent ? @ontology.parent : @ontology
    o.current_version
  end

  def download_path(resource)
    return nil if resource.versions.done.empty?
    repository_ontology_ontology_version_path(*resource_chain, resource.versions.done.latest.first)
  end

  def show_evaluate?
    show_oops? #|| show_foo?
  end
end

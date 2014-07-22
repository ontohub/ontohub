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

  def status_tag(resource)
    version = resource.is_a?(Ontology) ? resource.current_version : resource
    uri = repository_ontology_ontology_version_url(
      version.ontology.repository, version.ontology, version)
    html_opts = {
      class: 'ontology-version-state',
      data: {
        ontology_version_id: version.id,
        uri: uri,
        state: version.state,
      }
    }
    content_tag(:small, html_opts) do
      status(version)
    end
  end

  def status(resource)
    html = content_tag :span, resource.state

    if %w(pending downloading processing).include? resource.state
      html << " " << image_tag('spinner-16x16.gif', class: 'spinner')
    end

    if resource.state == 'failed' and resource.is_a? Ontology
      version = resource.versions.last

      link = ' ('
      link << link_to('error',
        [resource.repository, resource, :ontology_versions],
        :'data-original-title' => version.last_error,
        class: 'help'
      )
      link << ')'

      html << content_tag(:span, link.html_safe, class: 'error')
    end

    html
  end

end

module OntologyHelper

  def current_version
    o = @ontology.parent ? @ontology.parent : @ontology
    o.versions.current
  end

  def download_path(resource)
    return nil if resource.versions.done.empty?
    repository_ontology_ontology_version_path(*resource_chain, resource.versions.done.latest.first)
  end

  def repository
    @ontology.repository
  end
  
  def show_evaluate?
    show_oops? #|| show_foo?
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

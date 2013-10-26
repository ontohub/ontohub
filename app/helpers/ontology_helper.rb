module OntologyHelper
  
  def status(resource)
    html = content_tag :span, resource.state

    if %w(pending downloading processing).include? resource.state
      html << " " << image_tag('spinner-16x16.gif', class: 'spinner')
    end

    if resource.state == 'failed' and resource.is_a? Ontology
      version = resource.versions.last

      link = ' ('
      link << link_to('error',
        ontology_ontology_versions_path(resource),
        :'data-original-title' => version.last_error,
        class: 'help'
      )
      link << ')'

      html << content_tag(:span, link.html_safe, class: 'error')
    end

    html
  end

  def download_path(resource)
    return nil if resource.versions.done.empty?
    repository_ontology_ontology_version_path(*resource_chain, resource.versions.done.latest.first)
  end

  def in_process_tag
    ontologies = collection.in_process(admin? || current_user)
    content_tag(:div, class: 'well', id: 'ontology_infos') do
      content_tag(:h5, t(:in_process_ontologies)) +
      content_tag(:ul, id: 'in_process', class: 'ontologies') do
        render ontologies
      end
    end if ontologies.any?
  end

  def status_tag
    content_tag(:div, class: 'well', id: 'ontology_infos') do
      content_tag(:small, id: 'ontology-state',
                          class: @ontology.state,
                          :"data-uri" => repository_ontology_url(@ontology.repository, @ontology)) do
        status(@ontology)
      end
      # content_tag(:h5, t(:ontology_versions_status)) +
      # content_tag(:h6, "Status: #{@ontology.state}")
    end if @ontology.non_current_active_version?(current_user)
  end

end

# encoding: utf-8
module OntologyHelper
  
  def status(resource)
    html = content_tag :span, resource.state, class: "state #{resource.state}"

    if resource.state == 'pending'
      html << image_tag('spinner-16x16.gif', class: 'state spinner')
    end

    if resource.state == 'failed' and resource.is_a? Ontology
      version = resource.versions.last

      link = ' ('
      link << link_to('error',
        ontology_ontology_versions_path(resource),
        :'original-title' => version.last_error,
        class: 'help'
      )
      link << ')'

      html << content_tag(:span, link.html_safe, class: 'error')
    end

    html
  end
  
end

# encoding: utf-8
module OntologyHelper
  def status(resource)
    html = content_tag :span, resource.state, class: "state #{resource.state}"

    if resource.state == 'pending'
      html << image_tag('spinner-16x16.gif', class: 'state spinner')
    end

    html
  end
  
  def ontology_nav(ontology, current_page)
    pages = [
      [:overview,     ontology],
      [:axioms,      [ontology, :axioms], ontology.axioms_count],
      [:entites,     [ontology, :entities], ontology.entities_count],
      [:versions,    [ontology, :ontology_versions], ontology.versions.count],
      [:comments,    [ontology, :comments], ontology.comments.count]
    ]
    
    if can? :permissions, ontology
      pages << [:permissions, [ontology, :permissions], ontology.permissions.count]
    end
    
    @page_title = ontology.to_s
    @page_title = "#{current_page} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/ontologies/subnav', :locals => {
      ontology:     ontology,
      current_page: current_page,
      pages:        pages
    }
  end
end

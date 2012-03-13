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
      [:axioms,      [ontology, :axioms]],
      [:entites,     [ontology, :entities]],
      [:versions,    [ontology, :ontology_versions]],
      [:metadata,    [ontology, :metadata]]
      [:comments,    [ontology, :comments]]
    ]
    
    if can? :permissions, ontology
      pages << [:permissions, [ontology, :permissions]]
    end
    
    @page_title = ontology.to_s
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/ontologies/subnav', :locals => {
      ontology:     ontology,
      current_page: current_page,
      pages:        pages
    }
  end
end

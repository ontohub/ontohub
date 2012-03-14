# encoding: utf-8
module NavigationHelper
    
  def subnavigation(resource, pages, current_page)
    
    # add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << resource.send(counter_key) if resource.respond_to?(counter_key)
    end
    
    @page_title = resource.to_s
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/shared/subnavigation', :locals => {
      resource:     resource,
      current_page: current_page,
      pages:        pages
    }
  end
  
  def ontology_nav(ontology, current_page)
    pages = [
      [:overview,     ontology],
      [:axioms,      [ontology, :axioms]],
      [:entities,    [ontology, :entities]],
      [:versions,    [ontology, :ontology_versions]],
      [:metadata,    [ontology, :metadata]],
      [:comments,    [ontology, :comments]]
    ]
    
    pages << [:permissions, [ontology, :permissions]] if can? :permissions, ontology
    
    subnavigation(ontology, pages, current_page)
  end
  
  def team_nav(team, current_page)
    pages = [
      [:overview,     team],
      [:permissions, [team, :permissions]]
    ]
    
    pages << [:members,     [team, :team_users]] if can? :edit, team
    
    subnavigation(team, pages, current_page)
  end
  
end

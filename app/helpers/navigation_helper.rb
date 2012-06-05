# encoding: utf-8
module NavigationHelper
    
  def subnavigation(resource, pages, current_page, additional_actions = [])
    
    # add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << resource.send(counter_key) if resource.respond_to?(counter_key)
    end
    
    @page_title = resource.to_s
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/shared/subnavigation', :locals => {
      resource:           resource,
      current_page:       current_page,
      pages:              pages,
      additional_actions: additional_actions
    }
  end
  
  def ontology_nav(ontology, current_page)
    version = ontology.versions.current
    pages = [
      [:overview,     ontology],
      [:sentences,   [ontology, version, :sentences]],
      [:entities,    [ontology, version, :entities]],
      [:versions,    [ontology, :ontology_versions]],
      [:metadata,    [ontology, :metadata]],
      [:comments,    [ontology, :comments]]
    ]
    actions = []
    
    # nav link to permissions
    pages << [:permissions, [ontology, :permissions]] if can? :permissions, ontology
    
    # action link to new version
    actions << link_to('New version', [:new, ontology, :ontology_version ]) if can? :edit, ontology
    
    subnavigation(ontology, pages, current_page, actions)
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

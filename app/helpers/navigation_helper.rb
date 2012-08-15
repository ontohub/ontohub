# encoding: utf-8
module NavigationHelper

  def ontology_nav(ontology, current_page)

    @grouped_kinds = ontology.entities.grouped_by_kind
    pages = []
    
    if ontology.distributed?
      pages << [:children,  [ontology, :children]]
    else
      pages << [:symbols,   [ontology, :entities]] if @grouped_kinds.blank?
      pages << [:sentences, [ontology, :sentences]]
    end

    actions = []

    # action link to new version
    actions << link_to('New version', [:new, ontology, :ontology_version ]) if can? :edit, ontology
    
    # add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << ontology.send(counter_key) if ontology.respond_to?(counter_key)
    end
    
    @page_title = ontology.to_s
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/shared/ontology', :locals => {
      resource:           ontology,
      current_page:       current_page,
      pages:              pages,
      additional_actions: []
    }
  end
     
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

  def team_nav(team, current_page)
    pages = [
      [:overview,     team],
      [:permissions, [team, :permissions]]
    ]
    
    pages << [:members,     [team, :team_users]] if can? :edit, team
    
    subnavigation(team, pages, current_page)
  end
  
end

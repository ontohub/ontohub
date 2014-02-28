# encoding: UTF-8
module NavigationHelper

  def repository_nav(resource, current_page, options = {})
    pages = [
      [:overview,     resource]
    ]
    
    chain = resource_chain.last.is_a?(Ontology) ? resource_chain[0..-2] : resource_chain

    pages << [:ontologies,       [*chain, :ontologies]]
    pages << [:"File browser", [*chain, :tree]]
    pages << [:"URL catalog",  repository_url_maps_path(resource)]
    pages << [:history,          repository_ref_path(resource, 'master', path: nil, action: :history)]
    pages << [:errors,           repository_errors_path(resource)]
    pages << [:permissions,      [*chain, :permissions]] if can? :permissions, resource
 
    subnavigation(resource, pages, current_page, [], options)
  end

  def ontology_nav(ontology, current_page)
    @top_level_pages = [
      ['Content', ontology.distributed? ? :children : :entities],
      ['Comments', :comments],
      ['Metadata', :metadata],
      ['Versions', :ontology_versions],
      ['Graphs', :graphs],
      ['Mappings', :links]
    ]

    @metadatas = []

    if params[:action] != "edit"
      @metadatas = ontology_nav_metadata
    end

    @entities = ontology.distributed? ? [] : ontology.entities.groups_by_kind

    @active_kind = @entities.first.kind if current_page == :entities
    @active_kind = params[:kind] if params[:kind]

    pages = []
    
    if ontology.distributed?
      pages << [:children,  [*resource_chain, :children]]
    else
      pages << [:sentences, [*resource_chain, :sentences]]
    end

    actions = []
    
    # Add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << ontology.send(counter_key) if ontology.respond_to?(counter_key)
    end
    
    @page_title = ontology.to_s
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/ontologies/info', :locals => {
      resource:           ontology,
      current_page:       current_page,
      pages:              pages,
      additional_actions: []
    }
  end
     
  def subnavigation(resource, pages, current_page, additional_actions = [], options = {})
    # Add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << resource.send(counter_key) if resource.respond_to?(counter_key)
    end
    
    @page_title = current_page
    @page_title = "#{current_page.capitalize} · #{@page_title}" if current_page != pages[0][0]
    
    render :partial => '/shared/subnavigation', :locals => {
      resource:           resource,
      current_page:       current_page,
      pages:              pages,
      additional_actions: additional_actions,
      options:            options
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

  def active_navigation(controller)
    if params[:repository_id]
      if params[:ontology_id]
        'active' if controller == :ontologies
      else
        'active' if controller == :repositories
      end
    else
      'active' if [controller.to_s, controller.to_s.gsub('_', '/')].include? params[:controller]
    end
  end

  def menu_entry(title, controller)
    content_tag :li, class: active_navigation(controller) do
      link_to title, controller
    end
  end


  # used for activating tabs in ontology view
  def in_subcontroller?(page, current_page)
    case page
      when :entities
        %w(classes sentences).include? controller_name
      when :metadata
        in_metadata?
    end
  end

  # used for activating tabs in ontology view
  def in_metadata?
    ontology_nav_metadata.map{ |m| m[1][-1].to_s }.include? controller_name
  end

  protected

  def ontology_nav_metadata
    [
      ['Projects',         [*resource_chain, :projects]],
      ['Categories',       [*resource_chain, :categories]],
      ['Tasks',            [*resource_chain, :tasks]],
      ['License Model',    [*resource_chain, :license_models]],
      ['Formality Levels', [*resource_chain, :formality_levels]]
    ]
  end

end

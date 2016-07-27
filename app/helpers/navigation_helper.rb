# encoding: UTF-8
module NavigationHelper
  def repository_nav(resource, current_page, options = {})
    pages = [
      [:overview,     resource]
    ]

    chain = resource_chain.last.is_a?(Ontology) ? resource_chain[0..-2] : resource_chain

    pages << [:ontologies,       [*chain, :ontologies]]
    pages << [:"File browser", [*chain, :tree]]
    pages << [:history,          repository_ref_path(resource, 'master', path: nil, action: :history)]
    pages << [:settings,  repository_repository_settings_path(resource)]

    subnavigation(resource, pages, current_page, options, [])
  end

  def ontology_nav(ontology, current_page)
    resource = resource_chain.last

    content_page = ontology.distributed? ? :children : :symbols
    @top_level_pages = [
      ['Content', url_for([resource, content_page]),
       content_page.to_sym],
      ['Comments', url_for([resource, :comments]),
       :comments],
      ['Metadata', url_for([resource, :metadata]),
       :metadata],
      ['Versions', url_for([resource, :ontology_versions]),
       :ontology_versions],
      ['Graphs', url_for([resource, :graphs]),
       :graphs],
      ['Mappings', url_for([resource, :mappings]),
       :mappings],
    ]

    @metadatas = []

    if params[:action] != "edit"
      @metadatas = ontology_nav_metadata
    end

    @symbols =
      if ontology.distributed?
        []
      else
        ontology.symbols.groups_by_kind.sort_by(&:kind)
      end

    @active_kind =
      choose_default_symbol_kind(@symbols) if current_page == :symbols
    @active_kind = params[:kind] if params[:kind]

    pages = []

    if ontology.distributed?
      pages << [:children, url_for([resource_chain.last, :children])]
    else
      pages << [:axioms, url_for([resource_chain.last, :axioms])]
      pages << [:theorems, url_for([resource_chain.last, :theorems])]
    end

    actions = []

    pages.map! do |page|
      method = page.first
      count =
        if %i(axioms theorems).include?(page.first)
          ontology.send(method).original.count
        elsif ontology.respond_to?(method)
          ontology.send(method).count
      end
      [*page, count]
    end

    @page_title = ontology.to_s
    if current_page != pages[0][0]
      @page_title = "#{current_page.capitalize} · #{@page_title}"
    end

    render partial: '/ontologies/info', locals: {
      resource:           ontology,
      current_page:       current_page,
      pages:              pages,
      additional_actions: []
    }
  end

  def subnavigation(resource, pages, current_page, options = {},
    additional_actions = [], partial: '/shared/subnavigation')
    # Add counters
    pages.each do |row|
      counter_key = "#{row[0]}_count"
      row << resource.send(counter_key) if resource.respond_to?(counter_key)
    end

    @page_title = current_page
    if current_page != pages[0][0]
      @page_title = "#{current_page.capitalize} · #{@page_title}"
    end

    render partial: partial, locals: {
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
    alternatives = [controller.to_s, controller.to_s.gsub('_', '/')]
    if params[:repository_id]
      if params[:ontology_id]
        'active' if controller == :ontologies
      else
        'active' if controller == :repositories
      end
    elsif alternatives.include?(controller_name)
      'active'
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
    when :symbols
      %w(classes axioms theorems proof_attempts prover_outputs).include?(controller_name)
    when :metadata
      in_metadata?
    end
  end

  # used for activating tabs in ontology view
  def in_metadata?
    ontology_nav_metadata.map { |m| m.last.to_s }.
      include?(controller_name)
  end

  protected

  def ontology_nav_metadata
    resource = resource_chain.last
    [
      ['Projects', url_for([resource, :projects]),
       :projects],
      ['Tasks', url_for([resource, :tasks]),
       :tasks],
      ['License Models', url_for([resource, :license_models]),
       :license_models],
      ['Formality Levels', url_for([resource, :formality_levels]),
       :formality_levels],
    ]
  end

  def repository_settings_nav(repository, current_page)
    pages = []
    chain =
      if resource_chain.last.is_a?(Ontology)
        resource_chain[0..-2]
      else
        resource_chain
      end
    current_page = t("repository.#{current_page}")
    pages << [t('repository.urlmaps'), repository_url_maps_path(repository)]
    pages << [t('repository.errors'), repository_errors_path(repository)]
    if can? :permissions, repository
      pages << [t('repository.permissions'), [*chain, :permissions]]
    end
    if can? :edit, repository
      pages << [t('repository.edit'), edit_repository_path(repository)]
    end

    subnavigation(repository, pages, current_page,
      partial: '/repository_settings/subnav')
  end
end

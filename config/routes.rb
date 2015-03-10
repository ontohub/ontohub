require 'sidekiq/web' if defined? Sidekiq
require Rails.root.join('lib', 'router_constraints.rb')

Specroutes.define(Ontohub::Application.routes) do

  resources :filetypes, only: :create

  # IRI Routing #
  ###############
  # as per Loc/Id definition

  # Special (/ref-based) Loc/Id routes
  specified_get '/ref/:reference/:repository_id/*locid' => 'ontologies#show',
    as: :ontology_iri_versioned,
    constraints: [
      RefLocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'
      accept 'text/plain'
      accept 'application/json'

      doc title: 'Ontology IRI (loc/id) with version reference',
          body: <<-BODY
Will return a representation of the ontology at a
ontology version referenced by the {reference}.
      BODY
    end

  # MMT-Support
  specified_get '/ref/mmt/:repository_id/*path' => 'ontologies#show',
    as: :ontology_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'
      accept 'text/plain'
      accept 'application/json'

      doc title: 'MMT reference to an ontology',
          body: <<-BODY
Will return a representation of the ontology. The ontology
is determined according to the *path and to the MMT-query-string.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'mappings#show',
    as: :ontology_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Mapping, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'MMT reference to a mapping',
          body: <<-BODY
Will return a representation of the mapping. The mapping
is determined according to the *path and to the MMT-query-string.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'symbols#index',
    as: :ontology_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(OntologyMember::Symbol, ontology: :ontology_id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'MMT reference to a symbol',
          body: <<-BODY
Will return a representation of the symbol. The symbol
is determined according to the *path and to the MMT-query-string.
Currently the representation ist a list of all symbols in the ontology.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'sentences#index',
    as: :ontology_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Sentence, ontology: :ontology_id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'MMT reference to a sentence',
          body: <<-BODY
Will return a representation of the sentence. The sentence
is determined according to the *path and to the MMT-query-string.
Currently the representation is a list of all sentences in the ontology.
      BODY
    end

  # Subsites for ontologies
  ontology_subsites = %i(
    mappings symbols children
    sentences theorems comments
    metadata ontology_versions graphs
    projects categories tasks license_models formality_levels
  )

  ontology_subsites.each do |category|
    specified_get "/:repository_id/*locid///#{category}" => "#{category}#index",
      as: :"ontology_iri_#{category}",
      constraints: [
        LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
      ] do
        accept 'text/html'
        accept 'application/json'

        doc title: "Ontology subsite about #{category.to_s.gsub(/_/, ' ')}",
            body: <<-BODY
Will provide a subsite of a specific ontology.
        BODY
      end
  end

  # Loc/Id-Show(-equivalent) routes
  ######
  specified_get '/:repository_id/*locid' => 'ontologies#show',
    as: :ontology_iri,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'
      accept 'text/plain'
      accept 'application/json'

      doc title: 'loc/id reference to an ontology',
          body: <<-BODY
Will return a representation of the ontology. The ontology
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'mappings#show',
    as: :mapping_iri,
    constraints: [
      LocIdRouterConstraint.new(Mapping, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'loc/id reference to a mapping',
          body: <<-BODY
Will return a representation of the mapping. The mapping
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'symbols#index',
    as: :symbol_iri,
    constraints: [
      LocIdRouterConstraint.new(OntologyMember::Symbol, ontology: :ontology_id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'loc/id reference to a symbol',
          body: <<-BODY
Will return a representation of the symbol. The symbol
is determined according to the *locid.
Currently this will return the list of all symbols of the ontology.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'sentences#index',
    as: :ontology_iri,
    constraints: [
      LocIdRouterConstraint.new(Sentence, ontology: :ontology_id),
    ] do
      accept 'text/html'
      accept 'application/json'

      doc title: 'loc/id reference to a sentence',
          body: <<-BODY
Will return a representation of the sentence. The sentence
is determined according to the *locid.
Currently this will return the list of all sentence of the ontology.
      BODY
    end

  #
  ###############

  resources :ontology_types, only: :show
  get '/after_signup', to: 'home#show' , as: 'after_sign_up'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }
  resources :users, only: :show
  resources :keys, except: [:show, :edit, :update]

  resources :logics, only: [:index, :show] do
    resources :supports, :only => [:create, :update, :destroy, :index]
    resources :graphs, :only => [:index]
  end

  resources :languages do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end

  resources :language_mappings
  resources :logic_mappings

  resources :mappings, only: :index

  resources :categories, :only => [:index, :show]
  resources :projects
  resources :tasks
  resources :license_models
  resources :formality_levels


  resources :language_adjoints
  resources :logic_adjoints

  resources :serializations

  namespace :admin do
    resources :teams, :only => :index
    resources :users
    resources :jobs, :only => :index
    resources :status, only: :index
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => 'admin/sidekiq'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :categories,   only: [:index]
      resources :repositories, only: [:index, :update]
      resources :ontologies,   only: [:index, :update]
    end
  end

  resources :ontologies, only: [:index] do
    collection do
      get 'search' => 'ontology_search#search'
    end
  end

  resources :mappings do
    get 'update_version', :on => :member
  end

  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end

  get 'autocomplete' => 'autocomplete#index'
  get 'symbols_search' => 'symbols_search#index'

  resources :repositories do
    post 'undestroy',
      controller: :repositories,
      action: :undestroy,
      as: :undestroy

    resources :s_s_h_access, :only => :index, path: 'ssh_access'
    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :url_maps, except: :show
    resources :errors, :only => :index
    resources :repository_settings, :only => :index

    resources :ontologies, only: [:index, :show, :edit, :update, :destroy] do
      collection do
        post 'retry_failed' => 'ontologies#retry_failed'
        get 'search' => 'ontology_search#search'
      end
      member do
        post 'retry_failed' => 'ontologies#retry_failed'
      end
      resources :children, :only => :index
      resources :symbols, only: %i(index show)
      resources :sentences, :only => %i(index show)
      resources :theorems, only: :index
      resources :mappings do
        get 'update_version', :on => :member
      end
      resources :ontology_versions, :only => [:index, :show, :new, :create], :path => 'versions' do
        resource :oops_request, :only => [:show, :create]
      end
      resources :categories
      resources :tasks
      resources :license_models
      resources :tools
      resources :projects

      resources :metadata, :only => [:index, :create, :destroy]
      resources :comments, :only => [:index, :create, :destroy]
      resources :graphs, :only => [:index]
      resources :formality_levels

    end

    resources :files, only: [:new, :create]
    resources :repository_directories, only: [:create]

    get ':ref/files(/*path)',
      controller:  :files,
      action:      :show,
      as:          :ref,
      constraints: FilesRouterConstraint.new

    get ':ref/history(/:path)',
      controller:  :history,
      action:      :show,
      as:          :history,
      constraints: { path: /.*/ }

    get ':ref/diff',
      controller:  :diffs,
      action:      :show,
      as:          :diffs

    # action: entries_info
    get ':ref/:action(/:path)',
      controller:  :files,
      as:          :ref,
      constraints: { path: /.*/ }
  end

  post ':repository_id/:path',
    controller:  :files,
    action:      :update,
    as:          :repository_tree,
    constraints: { path: /.*/ }

  get ':repository_id(/*path)',
    controller: :files,
    action:     :show,
    as:         :repository_tree,
    constraints: FilesRouterConstraint.new

  get '*path',
    controller:  :ontologies,
    action:      :show,
    as:          :iri,
    constraints: IRIRouterConstraint.new

  root :to => 'home#index'

end

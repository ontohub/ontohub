require 'sidekiq/web' if defined? Sidekiq
require Rails.root.join('lib', 'router_constraints.rb')

Specroutes.define(Ontohub::Application.routes) do

  resources :filetypes, only: :create

  # IRI Routing #
  ###############
  #
  # as per Loc/Id definition

  specified_get '/:repository_id/*locid?symbols' => 'symbols#index',
    as: :ontology_iri_symbols,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
      MIMERouterConstraint.new('text/html'),
    ]

  specified_get '/:repository_id/*locid?children' => 'children#index',
    as: :ontology_iri_children,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
      MIMERouterConstraint.new('text/html'),
    ]

  specified_get '/:repository_id/*locid' => 'ontologies#show',
    as: :ontology_iri,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
      MIMERouterConstraint.new('text/plain', 'text/html'),
    ]

  specified_get '/:repository_id/*locid' => 'mappings#show',
    as: :mapping_iri,
    constraints: [
      LocIdRouterConstraint.new(Mapping, ontology: :ontology_id, element: :id),
      MIMERouterConstraint.new('text/plain', 'text/html'),
    ]

  specified_get '/:repository_id/*locid' => 'symbols#index',
    as: :symbol_iri,
    constraints: [
      LocIdRouterConstraint.new(OntologyMember::Symbol, ontology: :ontology_id),
      MIMERouterConstraint.new('text/html'),
    ]

  specified_get '/:repository_id/*locid' => 'sentences#index',
    as: :ontology_iri,
    constraints: [
      LocIdRouterConstraint.new(Sentence, ontology: :ontology_id),
      MIMERouterConstraint.new('text/plain', 'text/html'),
    ]

  get 'ref/:version_number/:repository_id(/*path)/:file',
    controller:  :ontologies,
    action:      :show,
    as:          :versioned_ontology_iri,
    constraints: GroupedConstraint.new(
      RefIRIRouterConstraint.new,
      MIMERouterConstraint.new('text/plain', 'text/html'))
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
      resources :symbols, only: :index
      resources :sentences, :only => :index
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

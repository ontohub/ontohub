require 'sidekiq/web' if defined? Sidekiq
require Rails.root.join('lib', 'router_constraints.rb')

Ontohub::Application.routes.draw do

  resources :ontology_types, only: :show
  get '/after_signup', to: 'home#show' , as: 'after_sign_up'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }
  resources :users, only: :show
  resources :keys, except: [:show, :edit, :update]

  resources :logics do
    resources :supports, :only => [:create, :update, :destroy, :index]
    resources :graphs, :only => [:index]
  end

  resources :languages do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end

  resources :language_mappings
  resources :logic_mappings

  resources :links, :only => :index

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
      get 'keywords' => 'ontology_search#keywords'
      get 'search' => 'ontology_search#search'
      get 'filters_map' => 'ontology_search#filters_map'
    end
  end

  resources :links do
    get 'update_version', :on => :member
  end

  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end

  get 'autocomplete' => 'autocomplete#index'
  get 'entities_search' => 'entities_search#index'

  resources :repositories do
    resources :s_s_h_access, :only => :index, path: 'ssh_access'
    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :url_maps, except: :show
    resources :errors, :only => :index
    resources :repository_settings, :only => :index

    resources :ontologies, only: [:index, :show, :edit, :update, :destroy] do
      collection do
        post 'retry_failed' => 'ontologies#retry_failed'
        get 'keywords' => 'ontology_search#keywords'
        get 'search' => 'ontology_search#search'
        get 'filters_map' => 'ontology_search#filters_map'
      end
      member do
        post 'retry_failed' => 'ontologies#retry_failed'
      end
      resources :children, :only => :index
      resources :entities, :only => :index
      resources :sentences, :only => :index
      resources :links do
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

    # action: history, diff, entries_info, files
    get ':ref/files(/*path)',
      controller:  :files,
      action:      :show,
      as:          :ref,
      constraints: FilesRouterConstraint.new

    # action: history, diff, entries_info, files
    get ':ref/:action(/:path)',
      controller:  :files,
      as:          :ref,
      constraints: { path: /.*/ }

    # get ':ref/files(/:path)',
    #   controller: :files,
    #   action:     :files,
    #   as:         :ref,
    #   constraints: FilesRouter.new
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

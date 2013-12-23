require 'sidekiq/web' if defined? Sidekiq


Ontohub::Application.routes.draw do
  
  resources :categories, :only => [:index, :show]

  resources :ontology_types, only: :show
  resources :formality_levels, only: :show

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
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


  resources :language_adjoints
  resources :logic_adjoints

  resources :serializations

  namespace :admin do
    resources :teams, :only => :index
    resources :users
    resources :jobs, :only => :index
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
    end
  end

  resources :links do
    get 'update_version', :on => :member
    resources :link_versions
  end

  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end

  get 'autocomplete' => 'autocomplete#index'
  get 'entities_search' => 'entities_search#index'

  resources :repositories do
    resources :ssh_access, :only => :index
    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :url_maps, except: :show
    resources :errors, :only => :index

    resources :ontologies, only: [:index, :show, :edit, :update] do
      collection do
        post 'retry_failed' => 'ontologies#retry_failed'
        get 'keywords' => 'ontology_search#keywords'
        get 'search' => 'ontology_search#search'
      end
      member do
        post 'retry_failed' => 'ontologies#retry_failed'
      end
      resources :children, :only => :index
      resources :entities, :only => :index
      resources :sentences, :only => :index
      resources :links do
        get 'update_version', :on => :member
        resources :link_versions
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
      resources :formality_levels, :only => [:index]

    end

    resources :files, only: [:new, :create]

    # action: history, diff, entries_info, files
    get ':ref/:action(/:path)',
      controller:  :files,
      as:          :ref,
      constraints: { path: /.*/ }
  end

  get ':repository_id(/:path)',
    controller:  :files,
    action:      :files,
    as:          :repository_tree,
    constraints: { path: /.*/ }

  root :to => 'home#show'

end

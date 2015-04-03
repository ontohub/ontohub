require 'sidekiq/web' if defined? Sidekiq
require Rails.root.join('lib', 'router_constraints.rb')

Specroutes.define(Ontohub::Application.routes) do

  resources :filetypes, only: :create

  # IRI Routing #
  ###############
  # as per Loc/Id definition

  # Special (/ref-based) Loc/Id routes
  specified_get '/ref/:reference/:repository_id/*locid' => 'api/v1/ontology_versions#show',
    as: :ontology_iri_versioned,
    constraints: [
      RefLocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
    ] do
      accept 'application/json', constraint: true
      accept 'text/plain', constraint: true
      # reroute_on_mime 'application/json', to: 'api/v1/ontology_versions#show'

      doc title: 'Ontology IRI (loc/id) with version reference',
          body: <<-BODY
Will return a representation of the ontology at a
ontology version referenced by the {reference}.
      BODY
    end

  specified_get '/ref/:reference/:repository_id/*locid' => 'ontologies#show',
    as: :ontology_iri_versioned,
    constraints: [
      RefLocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'

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
      reroute_on_mime 'text/plain', to: 'api/v1/ontologies#show'
      reroute_on_mime 'application/json', to: 'api/v1/ontologies#show'

      doc title: 'MMT reference to an ontology',
          body: <<-BODY
Will return a representation of the ontology. The ontology
is determined according to the *path and to the MMT-query-string.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'mappings#show',
    as: :mapping_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Mapping, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/mappings#show'

      doc title: 'MMT reference to a mapping',
          body: <<-BODY
Will return a representation of the mapping. The mapping
is determined according to the *path and to the MMT-query-string.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'symbols#index',
    as: :symbol_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(OntologyMember::Symbol, ontology: :ontology_id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/symbols#show'

      doc title: 'MMT reference to a symbol',
          body: <<-BODY
Will return a representation of the symbol. The symbol
is determined according to the *path and to the MMT-query-string.
Currently the representation ist a list of all symbols in the ontology.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'axioms#index',
    as: :axiom_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Axiom, ontology: :ontology_id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/axioms#show'

      doc title: 'MMT reference to a axiom',
          body: <<-BODY
Will return a representation of the axiom. The axiom
is determined according to the *path and to the MMT-query-string.
Currently the representation is a list of all axioms in the ontology.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'theorems#show',
    as: :theorem_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Theorem, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'

      doc title: 'MMT reference to a theorem',
          body: <<-BODY
Will return a representation of the theorem. The theorem
is determined according to the *path and to the MMT-query-string.
Currently the representation is a list of all theorems in the ontology.
      BODY
    end

  specified_get '/ref/mmt/:repository_id/*path' => 'api/v1/sentences#show',
    as: :sentence_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(Sentence, ontology: :ontology_id),
    ] do
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
    comments metadata graphs
    projects categories tasks
  )

  ontology_api_subsites = %i(
    mappings symbols children
    axioms theorems
    ontology_versions
    license_models formality_levels
  )

  ontology_subsites.each do |category|
    specified_get "/:repository_id/*locid///#{category}" => "#{category}#index",
      as: :"ontology_iri_#{category}",
      constraints: [
        LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
      ] do
        accept 'text/html'

        doc title: "Ontology subsite about #{category.to_s.gsub(/_/, ' ')}",
            body: <<-BODY
Will provide a subsite of a specific ontology.
        BODY
      end
  end

  ontology_api_subsites.each do |category|
    specified_get "/:repository_id/*locid///#{category}" => "#{category}#index",
      as: :"ontology_iri_#{category}",
      constraints: [
        LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
      ] do
        accept 'text/html'
        reroute_on_mime 'application/json', to: "api/v1/#{category}#index"

        doc title: "Ontology subsite about #{category.to_s.gsub(/_/, ' ')}",
            body: <<-BODY
Will provide a subsite of a specific ontology.
        BODY
      end
  end

  specified_get "/:repository_id/*locid///sentences" => "api/v1/sentences#index",
    as: :"ontology_iri_sentences",
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
    ] do
      accept 'application/json'

      doc title: "Ontology subsite about sentences",
          body: <<-BODY
Will provide a subsite of a specific ontology.
      BODY
    end

  # Loc/Id-Show(-equivalent) routes
  ######
  specified_get '/:repository_id/*locid' => 'ontologies#show',
    as: :ontology_iri,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'text/plain', to: 'api/v1/ontologies#show'
      reroute_on_mime 'application/json', to: 'api/v1/ontologies#show'

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
      reroute_on_mime 'application/json', to: 'api/v1/mappings#show'

      doc title: 'loc/id reference to a mapping',
          body: <<-BODY
Will return a representation of the mapping. The mapping
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'symbols#index',
    as: :symbol_iri,
    constraints: [
      LocIdRouterConstraint.new(OntologyMember::Symbol, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/symbols#show'

      doc title: 'loc/id reference to a symbol',
          body: <<-BODY
Will return a representation of the symbol. The symbol
is determined according to the *locid.
Currently this will return the list of all symbols of the ontology.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'api/v1/sentences#show',
    as: :sentence_iri,
    constraints: [
      LocIdRouterConstraint.new(Axiom, ontology: :ontology_id, element: :id),
    ] do
      accept 'application/json'

      doc title: 'loc/id reference to an axiom',
          body: <<-BODY
Will return a representation of the axiom. The axiom
is determined according to the *locid.
Currently this will return the list of all axioms of the ontology.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'axioms#index',
    as: :axiom_iri,
    constraints: [
      LocIdRouterConstraint.new(Axiom, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/axioms#show'

      doc title: 'loc/id reference to an axiom',
          body: <<-BODY
Will return a representation of the axiom. The axiom
is determined according to the *locid.
Currently this will return the list of all axioms of the ontology.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'theorems#show',
    as: :theorem_iri,
    constraints: [
      LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/theorems#show'

      doc title: 'loc/id reference to a theorem',
          body: <<-BODY
Will return a representation of the theorem. The theorem
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'sentences#index',
    as: :sentence_iri,
    constraints: [
      LocIdRouterConstraint.new(Sentence, ontology: :ontology_id, element: :id),
    ] do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/sentences#show'

      doc title: 'loc/id reference to a sentence',
          body: <<-BODY
Will return a representation of the sentence. The sentence
is determined according to the *locid.
Currently this will return the list of all sentences of the ontology.
      BODY
    end

  specified_get '/:repository_id/*locid' => 'proof_attempts#show',
    as: :proof_attempt_iri,
    constraints: [
      LocIdRouterConstraint.new(ProofAttempt, ontology: :ontology_id, theorem: :theorem_id, element: :id),
    ] do
      accept 'text/html'
      # TODO: add api controller
      #reroute_on_mime 'application/json', to: 'api/v1/proof_attempts#show'

      doc title: 'loc/id reference to a proof attempt',
          body: <<-BODY
Will return a representation of the proof attempt. The proof attempt
is determined according to the *locid.
      BODY
    end

  specified_get '/ontology_types/:id' => 'ontology_types#show',
    as: :ontology_type do
    accept 'text/html'
    reroute_on_mime 'application/json', to: 'api/v1/ontology_types#show'

    doc title: 'IRI of an ontology type',
        body: <<-BODY
Will return a representation of the ontology type.
    BODY
  end

  specified_get '/logics/:id' => 'logics#show',
    as: :logic do
    accept 'text/html'
    reroute_on_mime 'text/xml', to: 'api/v1/logics#show'
    reroute_on_mime 'application/xml', to: 'api/v1/logics#show'
    reroute_on_mime 'application/rdf+xml', to: 'api/v1/logics#show'
    reroute_on_mime 'application/json', to: 'api/v1/logics#show'

    doc title: 'IRI of a logic',
        body: <<-BODY
Will return a representation of the logic.
    BODY
  end

  specified_get '/license_models/:id' => 'license_models#show',
    as: :license_model do
    accept 'text/html'
    reroute_on_mime 'application/json', to: 'api/v1/license_models#show'

    doc title: 'IRI of a license model',
        body: <<-BODY
Will return a representation of the license model.
    BODY
  end

  specified_get '/formality_levels/:id' => 'formality_levels#show',
    as: :formality_level do
    accept 'text/html'
    reroute_on_mime 'application/json', to: 'api/v1/formality_levels#show'

    doc title: 'IRI of a formality level',
        body: <<-BODY
Will return a representation of the formality level.
    BODY
  end
  #
  ###############

  get '/after_signup', to: 'home#show' , as: 'after_sign_up'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }
  resources :users, only: :show
  namespace 'users' do
    resource :api_keys, only: %w(create)
  end
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
      resources :axioms, only: %i(index show)
      resources :theorems, only: %i(index show) do
        resources :proof_attempts, only: :show
        get '/proofs/new', controller: :proofs, action: :new
        post '/proofs', controller: :proofs, action: :create
      end
      get '/proofs/new', controller: :proofs, action: :new
      post '/proofs', controller: :proofs, action: :create

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

  specified_get '/:id' => 'api/v1/repositories#show',
    as: :repository_iri do
      accept 'application/json', constraint: true

      doc title: 'loc/id reference to a repository',
          body: <<-BODY
Will return a representation of the repository. The repository
is determined according to its path, which is considered as
{id}.
      BODY
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

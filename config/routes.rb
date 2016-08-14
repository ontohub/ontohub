require 'sidekiq/web' if defined? Sidekiq
require 'sidekiq-status/web' if defined? Sidekiq::Status
require Rails.root.join('lib', 'router_constraints.rb')

Specroutes.define(Ontohub::Application.routes) do

  resources :filetypes, only: :create

  # IRI Routing #
  ###############
  # as per Loc/Id definition
  specified_get '/actions/:id' => 'api/v1/actions#show',
    as: :action_iri,
    format: :json do
      accept 'application/json', constraint: true
      doc title: 'An action that represents a long-running operation'
    end

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

  specified_get '/ref/mmt/:repository_id/*path' => 'theorems#index',
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

  specified_get '/ref/mmt/:repository_id/*path' => 'api/v1/proof_attempt_configurations#show',
    as: :proof_attempt_configuration_iri_mmt,
    constraints: [
      MMTRouterConstraint.new(ProofAttempt, element: :proof_attempt_id),
    ] do
      accept 'application/json'

      doc title: 'MMT reference to a proof attempt configuration',
          body: <<-BODY
Will return a representation of the proof attempt configuration. The proof
attempt configuration is determined according to the *path and to the
MMT-query-string.
      BODY
    end

  specified_post '/:repository_id/*locid///retry' => 'ontologies#retry_failed',
    as: :ontology_retry,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'

      doc title: 'Ontology retry parsing command',
          body: <<-BODY
Will parse the ontology again.
      BODY
    end

  # Subsites for ontologies
  ontology_subsites = %i(
    comments metadata graphs
    projects tasks
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

  specified_post '/:repository_id/*locid///prove' => 'proofs#create',
    as: :"theorem_prove",
    constraints: [
      LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :theorem_id),
    ] do
      accept 'text/html'

      doc title: 'loc/id reference to a theorem command',
          body: <<-BODY
Will return a representation of the theorem command. The theorem
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid///prove' => 'proofs#new',
    as: :theorem_prove,
    constraints: [
      LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :theorem_id),
    ] do
      accept 'text/html'

      doc title: 'loc/id reference to a theorem command',
          body: <<-BODY
Will return a representation of the theorem command. The theorem
is determined according to the *locid.
      BODY
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

  specified_get '/:repository_id/*locid///prove' => 'proofs#new',
    as: :ontology_prove,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
    ] do
      accept 'text/html'

      doc title: 'Ontology prove command',
          body: <<-BODY
Will provide a site to the ontology command.
      BODY
    end

  specified_post '/:repository_id/*locid///prove' => 'proofs#create',
    as: :ontology_prove,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :ontology_id),
    ] do
      accept 'text/html'

      doc title: 'Ontology prove command',
          body: <<-BODY
Will provide a site to the ontology command.
      BODY
    end

  specified_get '/:repository_id/*locid///edit' => 'ontologies#edit',
    as: :ontology_edit,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'

      doc title: 'Ontology edit command',
          body: <<-BODY
Will provide a site to the ontology command.
      BODY
    end

  specified_put '/:repository_id/*locid' => 'ontologies#update',
    as: :ontology_update,
    constraints: [
      LocIdRouterConstraint.new(Ontology, ontology: :id),
    ] do
      accept 'text/html'

      doc title: 'Ontology update command',
          body: <<-BODY
Will provide a site to the ontology command.
      BODY
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

  theorems_subsites = %i(proof_attempts)
  theorems_subsites.each do |subsite|
    specified_get "/:repository_id/*locid///#{subsite}" => "#{subsite}#index",
      as: :"theorem_iri_#{subsite}",
      constraints: [
        LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :theorem_id),
      ] do
        accept 'text/html'
        reroute_on_mime 'application/json', to: "api/v1/#{subsite}#index"

        doc title: 'loc/id reference to a theorem subsite',
            body: <<-BODY
  Will return a representation of the theorem subsite. The theorem
  is determined according to the *locid.
        BODY
      end
  end

  specified_post '/:repository_id/*locid///prove' => 'proofs#create',
    as: :theorem_prove,
    constraints: [
      LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :theorem_id),
    ] do
      accept 'text/html'

      doc title: 'loc/id reference to a theorem command',
          body: <<-BODY
Will return a representation of the theorem command. The theorem
is determined according to the *locid.
      BODY
    end

  specified_get '/:repository_id/*locid///prove' => 'proofs#new',
    as: :theorem_prove,
    constraints: [
      LocIdRouterConstraint.new(Theorem, ontology: :ontology_id, element: :theorem_id),
    ] do
      accept 'text/html'

      doc title: 'loc/id reference to a theorem command',
          body: <<-BODY
Will return a representation of the theorem command. The theorem
is determined according to the *locid.
      BODY
    end


  specified_get '/:repository_id/*locid' => 'prover_outputs#show',
    as: :"prover_output_iri",
    constraints: [
      LocIdRouterConstraint.new(ProverOutput, ontology: :ontology_id, theorem: :theorem_id, proof_attempt: :proof_attempt_id, element: :id),
    ] do
      accept 'application/json'
      reroute_on_mime 'application/json', to: "api/v1/prover_outputs#show"

      doc title: 'loc/id reference to a prover output',
          body: <<-BODY
  Will return a prover output.
  The prover output is determined according to the *locid.
      BODY
    end

  proof_attempt_api_subsites = %i(
    used_axioms generated_axioms
    used_theorems prover_output
  )
  proof_attempt_api_subsites.each do |subsite|
    specified_get "/:repository_id/*locid///#{subsite}" => "api/v1/proof_attempts##{subsite}",
      as: :"proof_attempt_iri_#{subsite}",
      constraints: [
        LocIdRouterConstraint.new(ProofAttempt, ontology: :ontology_id, theorem: :theorem_id, element: :id),
      ] do
        accept 'application/json'

        doc title: 'loc/id reference to a proof attempt subsite',
            body: <<-BODY
  Will return a subsite of the proof attempt. The proof attempt is determined
  according to the *locid.
        BODY
      end
  end

  sentence_types = %i(axiom theorem)
  sentence_api_subsites = %i(symbols)
  sentence_types.each do |type|
    sentence_api_subsites.each do |subsite|
      specified_get "/:repository_id/*locid///#{subsite}" => "api/v1/#{subsite}#index",
        as: :"#{type}_iri_#{subsite}",
        constraints: [
          LocIdRouterConstraint.new(type.to_s.camelize.constantize, ontology: :ontology_id, element: :"sentence_id"),
        ] do
          accept 'application/json'

          doc title: "loc/id reference to a #{type} subsite",
              body: <<-BODY
    Will return a representation of the #{type} subsite. The #{type}
    is determined according to the *locid.
          BODY
        end
    end
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

  specified_get '/:repository_id/*locid' => 'theorems#index',
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

  proof_attempt_configuration_api_subsites =
    %i(selected_axioms selected_theorems)
  proof_attempt_configuration_api_subsites.each do |subsite|
    specified_get "/:repository_id/*locid///proof-attempt-configuration///#{subsite}" => "api/v1/proof_attempt_configurations##{subsite}",
      as: :"proof_attempt_configuration_iri_#{subsite}",
      constraints: [
        LocIdRouterConstraint.new(ProofAttempt, element: :proof_attempt_id),
      ] do
        accept 'application/json'

        doc title: 'loc/id reference to a proof attempt configuration subsite',
            body: <<-BODY
  Will return a subsite of the proof attempt configuration. The proof attempt
  configuration is determined according to the *locid.
        BODY
      end
  end

  specified_get '/:repository_id/*locid///proof-attempt-configuration' => 'api/v1/proof_attempt_configurations#show',
    as: :proof_attempt_configuration_iri,
    constraints: [
      LocIdRouterConstraint.new(ProofAttempt, element: :proof_attempt_id),
    ] do
      accept 'application/json'

      doc title: 'loc/id reference to a proof attempt configuration',
          body: <<-BODY
Will return a representation of the proof attempt configuration. The proof attempt configuration
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
      reroute_on_mime 'application/json', to: 'api/v1/proof_attempts#show'

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

  specified_get '/proof_statuses' => 'api/v1/proof_statuses#index',
    as: :proof_statuses do
      accept 'application/json'

      doc title: 'index of proof statuses',
          body: <<-BODY
Will return a representation of the proof statuses index.
      BODY
    end

  specified_get '/proof_statuses/:id' => 'api/v1/proof_statuses#show',
                as: :proof_status do
      accept 'application/json'

      doc title: 'reference to a proof status',
          body: <<-BODY
Will return a representation of the proof status.
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
  resources :logic_mappings, except: %i(index show)
  specified_get '/logic_mappings' => 'logic_mappings#index',
    as: :logic_mapping do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/logic_mappings#index'

      doc title: 'index of logic mappings',
          body: <<-BODY
Will return a representation of the logic mappings index.
      BODY
    end

  specified_get '/logic_mappings/:id' => 'logic_mappings#show',
    as: :logic_mapping do
      accept 'text/html'
      reroute_on_mime 'application/json', to: 'api/v1/logic_mappings#show'

      doc title: 'id reference to a logic mapping',
          body: <<-BODY
Will return a representation of the logic mapping. The logic mapping
is determined according to the id.
      BODY
    end


  resources :mappings, only: :index

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
      resources :axioms, only: :index
      resources :theorems, only: :index do
        resources :proof_attempts, only: %i(index show) do
          member do
            post 'retry_failed' => 'proof_attempts#retry_failed'
          end
          resource :prover_output, only: :show
        end
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

  specified_post '/:repository_id///combinations' => 'api/v1/combinations#create',
    as: :repository_combinations_iri do
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

  delete ':repository_id/*path',
    controller: :files,
    action:     :destroy,
    as:         :repository_tree,
    constraints: FilesRouterConstraint.new

  get ':repository_id(/*path)',
    controller: :files,
    action:     :show,
    as:         :repository_tree,
    constraints: FilesRouterConstraint.new

  root :to => 'home#index'

end

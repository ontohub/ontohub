require 'resque/server'

auth_resque = ->(request) {
  request.env['warden'].authenticate? and request.env['warden'].user.admin?
}

Ontohub::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
  
  resources :logics do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end
  
  resources :languages do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end
  
  resources :language_mappings
  resources :logic_mappings

  resources :language_adjoints
  resources :logic_adjoints

  resources :serializations

  namespace :admin do
    resources :teams, :only => :index
    resources :users
  end

  constraints auth_resque do
    mount Resque::Server, :at => "/admin/resque"
  end
  
  resources :ontologies do
    resources :children, :only => :index
    resources :entities, :only => :index
    resources :sentences, :only => :index
    get 'bulk', :on => :collection
    resources :ontology_versions, :only => [:index, :show, :new, :create], :path => 'versions' do
      post 'oops', on: :member
    end

#	%w( entities sentences ).each do |name|
#	  get "versions/:number/#{name}" => "#{name}#index", :as => "ontology_version_#{name}"
#	end

    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :metadata, :only => [:index, :create, :destroy]
    resources :comments, :only => [:index, :create, :destroy]
  end
  
  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'
  get 'search'       => 'search#index'

  root :to => 'home#show'

end

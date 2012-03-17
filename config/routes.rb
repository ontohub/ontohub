require 'resque/server'

auth_resque = ->(request) {
  request.env['warden'].authenticate? and request.env['warden'].user.admin?
}

Ontohub::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
  
  namespace :admin do
    resources :logics, :except => [:show]
    resources :teams, :only => :index
    resources :users
  end

  constraints auth_resque do
    mount Resque::Server, :at => "/admin/resque"
  end

  resources :ontologies do
    get 'bulk', :on => :collection
    resources :entities, :only => :index
    resources :axioms,   :only => :index
    resources :ontology_versions, :only => [:index, :show, :new, :create], :path => 'versions'
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

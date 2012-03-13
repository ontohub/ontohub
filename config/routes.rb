Ontohub::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
  
  namespace :admin do
    resources :teams, :only => :index
    resources :users
  end

  resources :ontologies do
    resources :entities, :only => :index
    resources :axioms,   :only => :index
    resources :ontology_versions, :only => :index, :path => 'versions'
    resources :permissions, :only => [:index, :create, :update, :destroy]
    resources :metadata, :except => :show
    resources :comments, :only => [:index, :create]
  end
  
  resources :teams do
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'

  root :to => 'home#show'

end

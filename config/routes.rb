Ontohub::Application.routes.draw do
  
  devise_for :users
  
  namespace :admin do
    resources :users
  end

  resources :ontologies do
    resources :entities, :only => :index
    resources :axioms,   :only => :index
  end
  
  resources :teams do
    resources :team_users, :only => [:create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'

# root :to => 'home#show'
  root :to => 'ontologies#index'

end

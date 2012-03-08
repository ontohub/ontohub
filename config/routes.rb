Ontohub::Application.routes.draw do
  
  devise_for :users

  namespace :admin do
    resources :users
  end

  resources :ontologies do
    resources :entities
    resources :axioms
  end

# root :to => 'home#show'
  root :to => 'ontologies#index'

end

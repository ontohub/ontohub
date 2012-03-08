Ontohub::Application.routes.draw do
  
  devise_for :users

  namespace :admin do
    resources :users
  end

  resources :ontologies

  root :to => 'home#show'

end

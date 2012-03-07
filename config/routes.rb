Ontohub::Application.routes.draw do
  
  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  namespace :admin do
    resources :users
  end

  root :to => 'home#show'

  # See how all your routes lay out with "rake routes"

end

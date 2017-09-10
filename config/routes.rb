Rails.application.routes.draw do
  resources :games
  resources :lineups
  resources :teams
  resources :owners
  resources :leagues
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

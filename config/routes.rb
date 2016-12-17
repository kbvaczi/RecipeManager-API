Rails.application.routes.draw do
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html  
  
  namespace :recipes do
    resources :parses, only: [:create, :show]
  end
  resources :recipes
  
end

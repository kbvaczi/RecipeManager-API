Rails.application.routes.draw do

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    registrations:  'overrides/registrations',
    sessions:       'overrides/sessions'
  }

  resources :recipe_parses, only: [:create, :show]
  resources :recipes

end

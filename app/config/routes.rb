Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth' , controllers: {
    confirmations: 'overrides/confirmations',
    passwords: 'overrides/passwords',
    registrations: 'overrides/registrations',
  }
  resources :users, only: [:index, :show, :destroy] do
    member do
      post "lock"
      post "unlock"
    end
  end
  resources :session_histories, only: :index
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

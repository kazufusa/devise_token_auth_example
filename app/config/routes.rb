Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth' , controllers: {
    confirmations: 'overrides/confirmations'
  }
  resources :users, only: [:index, :show, :destroy] do
    member do
      post "lock"
      post "unlock"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

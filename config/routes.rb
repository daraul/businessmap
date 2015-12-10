Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", confirmations: "users/confirmations", passwords: "users/passwords" }
  
  resources :places do 
      resources :pictures, only: [:destroy] 
  end 
  root 'places#index'
  
  get 'you' => 'places#your_places', as: 'current_user_places'
end

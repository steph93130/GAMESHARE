Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get "profile", to: "profiles#show", as: :profile
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :games do
    resources :chats, only: [:create]
  end

  resources :chats, only: [:show] do
    resources :bookings, only: [:create, :update, :edit]
  end
  resources :chats, only: [:show] do
    resources :messages, only: [:create, :index, :show]
  end
resources :profile, only: [:show] do
  resources :bookings, only: [:index]
  
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "profiles/show2", to: "profiles#show2"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

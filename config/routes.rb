Rails.application.routes.draw do
  get "applications/index"
  resources :applications, only: [:index]
  devise_for :users
  #login
  post '/login', to: 'sessions#create'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
   get "service-worker" => "service_worker#index", defaults: { format: "js" }

  # Defines the root path route ("/")
  # root "posts#index"
  resources :events do
    collection do
      get :calendar  
      get :recent_pdf   
    end
    member do
      patch :approve
      patch :disapprove
      post :hide
      post :show_again
    end
  end
  resources :bands
  resources :venues
  resources :band_events, only: [:create, :update, :destroy]
  
  # Admin routes
  resources :admin_notifications, except: [:edit, :update]
  
  # Spotify API routes
  get 'spotify/search_artists', to: 'spotify#search_artists'
  get 'spotify/get_artist_info', to: 'spotify#get_artist_info'
  get '/service_worker.js', to: 'service_worker#index'
  
  root to: "home#index"
end

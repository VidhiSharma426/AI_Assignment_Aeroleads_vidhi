Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dashboard#index"

  # Dashboard routes
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/statistics', to: 'dashboard#statistics'

  # Phone numbers management
  resources :phone_numbers do
    collection do
      post :bulk_upload
      post :paste_numbers
      delete :clear_all
    end
    member do
      post :make_call
    end
  end

  # Call logs
  resources :call_logs, only: [:index, :show, :destroy] do
    collection do
      get :today
      get :statistics
      delete :clear_all
    end
  end

  # AI Command interface
  resources :ai_commands, only: [:create] do
    collection do
      post :process_text_command
      post :process_voice_command
    end
  end

  # API routes for AJAX calls
  namespace :api do
    namespace :v1 do
      resources :calls, only: [:create, :show, :index]
      resources :phone_numbers, only: [:index]
      get 'dashboard/stats', to: 'dashboard#stats'
    end
  end

  # Health check
  get '/health', to: 'application#health'
end
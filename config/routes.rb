Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      namespace :merchants do
        get '/find_all', to: 'search#find_all'
      end
      
      namespace :items do
        get '/find', to: 'search#find'
      end 

      resources :merchants do
        resources :items, module: :merchants, only: [:index]
      end

      resources :items, only: [:index, :show, :create, :update, :destroy] do
        resources :merchants, module: :items, only: [:index, :show]
      end
    end
  end
end

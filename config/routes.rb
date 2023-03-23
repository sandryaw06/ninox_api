Rails.application.routes.draw do
  resources :samsaras
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do 
      resources :trucks
      resources :transactions do
        
      end
      resources :samsaras do
        
      end
      get "/drivers", to: "samsaras#drivers"
    end
  end
end

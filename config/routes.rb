Rails.application.routes.draw do
  root "loans#index"
  resource :registration, only: %i[ new create ]
  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resources :items
  resources :borrowers
  resources :loans, except: :destroy do
    resource :return, only: :create, controller: "loan_returns"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end

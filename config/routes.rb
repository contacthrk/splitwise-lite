Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :expenses
  resources :settlements, only: :create

  root to: "static#dashboard"
  get 'people/:id', to: 'static#person', as: :person
end

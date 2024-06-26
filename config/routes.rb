Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :expenses, only: [:create, :show, :destroy]
  resources :settlements, only: [:create, :show, :destroy]

  root to: "static#dashboard"
  get 'people/:id', to: 'static#person', as: :person
end

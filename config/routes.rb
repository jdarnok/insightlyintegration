Rails.application.routes.draw do


  root to: 'visitors#index'
  devise_for :users,
             :controllers  => {
             :registrations => 'registrations'
            }
  resources :users
  resources :organisations, except: [:destroy]
  get 'organisations/order/:id', controller: 'organisations', action: 'order', as: 'order'
end

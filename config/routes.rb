Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "bills#new" rescue nil
  resources :bills, only: [:new, :create, :show]
  namespace :admin do
    resources :products
  end
end

Rails.application.routes.draw do
  root "listings#index"

  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get 'listings/browse', to: 'categories#index'
  post 'listings/:id/track', to: 'listings#follow', as: 'follow_listing'
  post 'listings/:id/stop_tracking', to: 'listings#unfollow', as: 'unfollow_listing'
  get 'listings/import', to: 'listings#new_import', as: 'new_import_listing'
  post 'listings/import', to: 'listings#import', as: 'import_listing'

  resources :listings do
    post 'applicant_review', to: 'listings#applicant_review'
    post 'donation_applications', to: 'donation_applications#create'
    get 'donation_application', to: 'donation_applications#show'
    post 'mailed_submission', to: 'donation_applications#update_mailed_submission', as: 'update_submission'
    post 'applicant_approve', to: 'donation_applications#approve_applicant'
    post 'applicant_decline', to: 'donation_applications#decline_applicant'
    post 'applicant_reset', to: 'donation_applications#reset_applicant'
  end

  resources :users, only: [:show] do
    resources :addresses
    resources :users_questionnaires, only: [:edit, :update], as: 'questionnaires'
    resources :contacts, to: 'contact_infos'
    get '/donations', to: 'listings#donation_history'
    get '/requests', to: 'listings#request_history'
    get '/watched_listings', to: 'listings#follow_history'
  end
end

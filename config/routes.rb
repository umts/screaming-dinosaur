# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#index'

  post :login, to: 'sessions#create' if Rails.env.development?
  post :logout, to: 'sessions#destroy'

  resources :rosters do
    member do
      get :setup
    end
    collection do
      get :assignments
    end

    resources :assignments, except: :show

    get :assign_weeks, to: 'week_assigners#prompt'
    post :assign_weeks, to: 'week_assigners#perform'

    get :assign_weekdays, to: 'weekday_assigners#prompt'
    post :assign_weekdays, to: 'weekday_assigners#perform'

    resources :users, except: %i[show destroy] do
      collection do
        post :transfer
        get :inactive
      end
    end
    get 'twilio/call', to: 'twilio#call', as: :twilio_call
    get 'twilio/text', to: 'twilio#text', as: :twilio_text
  end
  resources :versions do
    member do
      get 'undo'
    end
  end

  get 'feed/:roster/:token' => 'assignments#feed', as: :feed
end

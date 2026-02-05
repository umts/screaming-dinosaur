# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#index'

  post :login, to: 'sessions#create' if Rails.env.development?
  post :logout, to: 'sessions#destroy'

  resources :rosters do
    member do
      get :setup
    end

    resources :assignments, only: %i[new edit create update destroy]

    get :assign_weeks, to: 'week_assigners#prompt'
    post :assign_weeks, to: 'week_assigners#perform'

    get :assign_weekdays, to: 'weekday_assigners#prompt'
    post :assign_weekdays, to: 'weekday_assigners#perform'

    resources :memberships, only: %i[index create destroy update], shallow: true

    get 'twilio/call', to: 'twilio#call', as: :twilio_call
    get 'twilio/text', to: 'twilio#text', as: :twilio_text
  end

  resources :users, except: %i[show]

  resources :versions do
    member do
      post :undo
    end
  end

  get 'feed/:roster/:token' => 'feed#show', as: :feed

  mount MaintenanceTasks::Engine, at: '/maintenance_tasks'
end

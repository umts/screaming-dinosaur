# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#index'

  get 'feed/:roster_id/:token' => 'feed#show', as: :feed

  post :login, to: 'sessions#create' if Rails.env.development?
  post :logout, to: 'sessions#destroy'

  mount MaintenanceTasks::Engine, at: '/maintenance_tasks'

  resources :rosters do
    member do
      get :setup
    end

    resources :assignments, only: %i[index new edit create update destroy], shallow: true

    get :assign_weeks, to: 'week_assigners#prompt'
    post :assign_weeks, to: 'week_assigners#perform'

    get :assign_weekdays, to: 'weekday_assigners#prompt'
    post :assign_weekdays, to: 'weekday_assigners#perform'

    resources :memberships, only: %i[index create destroy update], shallow: true

    get 'twilio/call', to: 'twilio#call', as: :twilio_call
    get 'twilio/text', to: 'twilio#text', as: :twilio_text
  end

  resources :users, only: %i[index new edit create update destroy]

  resources :versions, only: [] do
    member do
      post :undo
    end
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#index'

  get 'feed/:roster_id/:token' => 'feed#show', as: :feed

  get '/auth/:provider/callback', to: 'sessions#create'
  post :logout, to: 'sessions#destroy'

  mount MaintenanceTasks::Engine, at: '/maintenance_tasks'

  resources :rosters do
    resources :assignments, only: %i[index new edit create update destroy], shallow: true do
      collection do
        get :generate, to: 'assignment_generator#prompt'
        post :generate, to: 'assignment_generator#perform'
      end

      member do
        get :take, to: 'assignment_takers#prompt'
        post :take, to: 'assignment_takers#perform'
      end
    end

    get :assignment_generator, to: 'assignment_generator#prompt'
    post :assignment_generator, to: 'assignment_generator#perform'


    resources :memberships, only: %i[index create destroy update], shallow: true

    get 'twilio/call', to: 'twilio#call', as: :twilio_call
    get 'twilio/text', to: 'twilio#text', as: :twilio_text
  end

  resources :users, only: %i[index new edit create update]

  resources :versions, only: [] do
    member do
      post :undo
    end
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  root 'rosters#assignments'

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

    namespace :assignments do
      get :generate_by_weekday, to: 'weekday_generators#prompt'
      post :generate_by_weekday, to: 'weekday_generators#perform'

      get :generate_rotation, to: 'rotation_generators#prompt'
      post :generate_rotation, to: 'rotation_generators#perform'
    end

    resources :users, except: :show do
      collection do
        post :transfer
        get :inactive
      end
    end
    get 'twilio/call', to: 'twilio#call', as: :twilio_call
    get 'twilio/text', to: 'twilio#text', as: :twilio_text
  end

  get 'changes/:id/undo', to: 'changes#undo', as: :undo_change

  get 'feed/:roster/:token' => 'assignments#feed', as: :feed
end

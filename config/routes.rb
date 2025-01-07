# frozen_string_literal: true

Rails.application.routes.draw do
  root 'rosters#assignments'

  resources :rosters do
    member do
      get :setup
    end
    collection do
      get :assignments
    end

    resources :assignments, except: :show do
      collection do
        get :generate_by_weekday
        post :generate_by_weekday, to: 'assignments#generate_by_weekday_submit'
      end
    end

    namespace :assignments do
      get :rotation_generator, to: 'rotation_generators#prompt'
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

  unless Rails.env.production?
    get  'sessions/dev_login', to: 'sessions#dev_login', as: :dev_login
    post 'sessions/dev_login', to: 'sessions#dev_login'
  end

  get 'sessions/unauthenticated', to: 'sessions#unauthenticated', as: :unauthenticated_session
  get 'sessions/destroy', to: 'sessions#destroy', as: :destroy_session

  get 'feed/:roster/:token' => 'assignments#feed', as: :feed
end

Rails.application.routes.draw do
  root 'assignments#index'

  resources :rotations, only: %i(index) do
    resources :assignments, except: :show do
      collection do
        post :generate_rotation
        get  :rotation_generator
      end
    end

    resources :users, except: :show
  end

  get 'twilio/call', to: 'twilio#call', as: :twilio_call
  get 'twilio/text', to: 'twilio#text', as: :twilio_text

  unless Rails.env.production?
    get  'sessions/dev_login', to: 'sessions#dev_login', as: :dev_login
    post 'sessions/dev_login', to: 'sessions#dev_login'
  end
  get 'sessions/unauthenticated', to: 'sessions#unauthenticated', as: :unauthenticated_session
  get 'sessions/destroy', to: 'sessions#destroy', as: :destroy_session
end

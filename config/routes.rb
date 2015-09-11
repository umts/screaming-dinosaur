Rails.application.routes.draw do
  root 'assignments#index'

  resources :assignments, except: :show

  resources :users, except: :show

  get 'twilio/call', to: 'twilio#call', as: :twilio_call
  get 'twilio/text', to: 'twilio#text', as: :twilio_text

  unless Rails.env.production?
    get  'sessions/dev_login', to: 'sessions#dev_login', as: :dev_login
    post 'sessions/dev_login', to: 'sessions#dev_login'
  end
  get 'sessions/unauthenticated', to: 'sessions#unauthenticated', as: :unauthenticated_session
  get 'sessions/destroy', to: 'sessions#destroy', as: :destroy_session
end

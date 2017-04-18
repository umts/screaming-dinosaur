Rails.application.routes.draw do
  root 'assignments#index'

  resources :rosters, except: %i(show) do
    resources :assignments, except: :show do
      collection do
        post :generate_rotation
        get  :rotation_generator
      end
    end

    resources :users, except: :show do
      collection do
        post :transfer
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
end

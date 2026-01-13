# frozen_string_literal: true

class SessionsController < ApplicationController
  if Rails.env.development?
    # :nocov:
    def create
      authorize!
      session[:user_id] = params[:user_id]
      redirect_back_or_to root_path
    end

    def destroy
      authorize!
      session.clear
      redirect_back_or_to root_path
    end
    # :nocov:
  else
    def destroy
      authorize!
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/saml2/idp/SingleLogoutService.php'
    end
  end
end

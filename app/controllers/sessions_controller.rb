# frozen_string_literal: true

class SessionsController < ApplicationController
  if Rails.env.local?
    def create
      authorize!
      session[:user_id] = params[:user_id]
      redirect_back_or_to root_path
    end
  end

  def destroy
    authorize!
    # :nocov:
    if Rails.env.development?
      session.clear
      redirect_back_or_to root_path
      # :nocov:
    else
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/saml2/idp/SingleLogoutService.php'
    end
  end
end

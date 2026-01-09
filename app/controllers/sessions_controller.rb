# frozen_string_literal: true

class SessionsController < ApplicationController
  if Rails.env.development?
    def create
      session[:user_id] = params[:user_id]
      redirect_back_or_to root_path
    end
  end

  def destroy
    if Rails.env.development?
      session.clear
      redirect_back_or_to root_path
    else
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/saml2/idp/SingleLogoutService.php'
    end
  end
end

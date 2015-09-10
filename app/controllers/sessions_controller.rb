class SessionsController < ApplicationController
  layout false
  skip_before_action :set_current_user

  def destroy
    session.clear
    if Rails.env.production?
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
    else redirect_to dev_login_url
    end
  end

  def dev_login # route not defined in production
    if request.get?
      @users = User.all
    elsif request.post?
      session[:user_id] = params[:user_id]
      redirect_to assignments_path
    end
  end

  # Only shows if no user in database AND no SPIRE provided from Shibboleth
  def unauthenticated
  end
end

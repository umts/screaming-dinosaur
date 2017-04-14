class SessionsController < ApplicationController
  layout false
  skip_before_action :set_current_user, :find_roster

  def destroy
    session.clear
    if Rails.env.production?
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
    else redirect_to dev_login_url
    end
  end

  def dev_login # route not defined in production
    if request.get?
      @rosters = Roster.includes(:users)
    elsif request.post?
      session[:user_id] = params[:user_id]
      redirect_to roster_assignments_path(roster_id: params[:roster_id])
    end
  end

  # Only shows if no user in database AND no SPIRE provided from Shibboleth
  def unauthenticated
  end
end

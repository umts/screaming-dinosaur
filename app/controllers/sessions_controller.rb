# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :check_primary_account, :set_current_user, :set_roster

  def destroy
    session.clear
    if Rails.env.production?
      redirect_to '/Shibboleth.sso/Logout?return=' \
                  'https://webauth.umass.edu/saml2/idp/SingleLogoutService.php'
    else
      redirect_to dev_login_url
    end
  end

  # route not defined in production
  def dev_login
    if request.get?
      @rosters = Roster.includes(:users)
    elsif request.post?
      session[:user_id] = params[:user_id]
      redirect_to roster_assignments_path(Roster.find(params[:roster_id]))
    end
  end

  def unauthenticated; end
end

# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_forgery_protection

  def create
    authorize!
    session[:entra_uid] = auth_hash.uid
    redirect_to auth_referer || root_path
  end

  def destroy
    authorize!
    session.clear
    # :nocov:
    if Rails.env.development?
      redirect_to root_path
      # :nocov:
    else
      redirect_to entra_logout_url, allow_other_host: true
    end
  end

  private

  def auth_hash = request.env['omniauth.auth']

  def auth_referer = request.env['omniauth.origin'].presence

  def entra_logout_url
    tenant_id = Rails.application.credentials.dig(:entra_id, :tenant_id)
    redirect_uri = CGI.escape(root_url)
    "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/logout?post_logout_redirect_uri=#{redirect_uri}"
  end
end

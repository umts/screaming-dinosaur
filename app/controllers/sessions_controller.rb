# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_forgery_protection only: :create

  def create
    authorize!
    store_auth_in_session
    sync_user_upn
    redirect_to auth_referer || root_path
  end

  def destroy
    authorize!
    session.clear
    if Rails.env.development?
      # :nocov:
      redirect_to root_path
      # :nocov:
    else
      redirect_to entra_logout_url, allow_other_host: true
    end
  end

  private

  def store_auth_in_session
    session[:entra_uid] = auth_hash.uid
    session[:email] = auth_hash.info.email
    session[:first_name] = auth_hash.info.first_name
    session[:last_name] = auth_hash.info.last_name
    session[:upn] = auth_hash.extra&.dig(:raw_info, 'upn')
  end

  def sync_user_upn
    return if session[:upn].blank?

    user = User.find_by(entra_uid: session[:entra_uid])
    return if user.nil? || user.upn == session[:upn]

    user.update!(upn: session[:upn])
  end

  def auth_hash = request.env['omniauth.auth']

  def auth_referer = request.env['omniauth.origin'].presence

  def entra_logout_url
    tenant_id = Rails.application.credentials.dig(:entra_id, :tenant_id)
    redirect_uri = CGI.escape(root_url)
    "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/logout?post_logout_redirect_uri=#{redirect_uri}"
  end
end

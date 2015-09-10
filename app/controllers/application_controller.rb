class ApplicationController < ActionController::Base
  attr_accessor :current_user
  before_action :set_current_user
  protect_from_forgery with: :exception

  def set_current_user
    if session.key? :user_id
      @current_user = User.find_by id: session[:user_id]
    elsif request.env.key? 'fcIdNumber'
      @current_user = User.find_by spire: request.env['fcIdNumber']
      session[:user_id] = @current_user.id
    else redirect_to unauthenticated_session_path
    end
  end
end

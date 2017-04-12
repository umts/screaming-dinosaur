class ApplicationController < ActionController::Base
  attr_accessor :current_user
  before_action :set_current_user, :find_rotation
  protect_from_forgery with: :exception

  # We want to share this logic between controllers, but we don't want it to be
  # run before all controller actions. So it lives here, but is selectively
  # invoked by the controllers.
  
  # If there's one specified, go to that.
  # Otherwise, go to the first rotation of which the current user is a member.
  # Finally, just go to the first rotation (if they're a member of none).
  def find_rotation
    @rotation = Rotation.find_by(id: params[:rotation_id])
    @rotation ||= @current_user.rotations.first
    @rotation ||= Rotation.first
  end

  def set_current_user
    if session.key? :user_id
      @current_user = User.find_by id: session[:user_id]
    else
      @current_user = User.find_by spire: request.env['fcIdNumber']
      if @current_user.present?
        session[:user_id] = @current_user.id
      else redirect_to unauthenticated_session_path
      end
    end
  end
end

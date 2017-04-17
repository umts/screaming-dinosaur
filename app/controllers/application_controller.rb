class ApplicationController < ActionController::Base
  attr_accessor :current_user
  before_action :set_current_user, :set_roster
  protect_from_forgery with: :exception

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

  # If there's one specified, go to that.
  # Otherwise, go to the first roster of which the current user is a member.
  # Finally, just go to the first roster (if they're a member of none).
  def set_roster
    @roster = Roster.find_by(id: params[:roster_id])
    @roster ||= @current_user.rosters.first
    @roster ||= Roster.first
  end
end

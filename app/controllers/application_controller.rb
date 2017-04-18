class ApplicationController < ActionController::Base
  attr_accessor :current_user
  before_action :set_current_user, :set_roster, :set_paper_trail_whodunnit
  protect_from_forgery with: :exception

  def confirm_change(object, message = nil)
    change = object.versions.where(whodunnit: @current_user.id.to_s).last
    # If we know what change occurred, use it to write the message.
    # If we don't, try and infer from the current controller action.
    # Otherwise, just go with 'updated'.
    if change.present?
      flash[:change] = change.id
      event = change.event
    else event = params[:action] || 'update'
    end
    action_taken = case event
                   when 'update', 'create' then change.event + 'd'
                   when 'destroy' then 'deleted'
                   end
    flash[:message] = "#{object.class.name} has been #{action_taken}."
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

  # If there's one specified, go to that.
  # Otherwise, go to the first roster of which the current user is a member.
  # Finally, just go to the first roster (if they're a member of none).
  def set_roster
    @roster = Roster.find_by(id: params[:roster_id])
    @roster ||= @current_user.rosters.first
    @roster ||= Roster.first
  end
end

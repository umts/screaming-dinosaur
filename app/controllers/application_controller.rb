class ApplicationController < ActionController::Base
  attr_accessor :current_user
  before_action :set_current_user, :set_roster, :set_paper_trail_whodunnit
  protect_from_forgery with: :exception

  def confirm_change(object, message = nil)
    change = object.versions.done_by(@current_user).last
    flash[:change] = change.try(:id)
    # If we know what change occurred, use it to write the message.
    # If we don't, try and infer from the current controller action.
    # Otherwise, just go with 'updated'.
    event = if change.present? then change.event
            else params[:action] || 'update'
            end
    action_taken = case event
                   when 'update', 'create' then event + 'd'
                   when 'destroy' then 'deleted'
                   end
    message ||= "#{object.class.name} has been #{action_taken}."
    flash[:message] = message
  end

  def report_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_to :back
  end

  # There are three levels of access:
  # 1. Regular users
  # 2. Admins in general (of any roster)
  # 3. Admins of specifically the current roster

  def require_admin
    # ... and return is correct here
    # rubocop:disable Style/AndOr
    head :unauthorized and return unless @current_user.admin?
    # rubocop:enable Style/AndOr
  end

  def require_admin_in_roster
    # ... and return is correct here
    # rubocop:disable Style/AndOr
    head :unauthorized and return unless @current_user.admin_in? @roster
    # rubocop:enable Style/AndOr
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

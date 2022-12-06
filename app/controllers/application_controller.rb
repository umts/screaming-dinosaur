# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_accessor :current_user

  before_action :check_primary_account, :set_current_user, :set_roster, :set_paper_trail_whodunnit

  def confirm_change(object, message = nil)
    change = object.versions.where(whodunnit: @current_user).last
    flash[:change] = change.try(:id)
    # If we know what change occurred, use it to write the message.
    # If we don't, try and infer from the current controller action.
    # Otherwise, just go with 'updated'.
    event = if change.present? then change.event
            else
              params[:action] || 'update'
            end
    action_taken = case event
                   when 'destroy' then 'deleted'
                   else
                     event.sub(/e?$/, 'ed')
                   end
    message ||= "#{object.class.name} has been #{action_taken}."
    flash[:message] = message
  end

  def report_errors(object, fallback_location:)
    flash[:errors] = object.errors.full_messages
    redirect_back fallback_location: fallback_location
  end

  # There are three levels of access:
  # 1. Regular users
  # 2. Admins in general (of any roster)
  # 3. Admins of specifically the current roster

  def require_admin
    render file: 'public/401.html', status: :unauthorized unless @current_user.admin?
  end

  def require_admin_in_roster
    render file: 'public/401.html', status: :unauthorized unless @current_user.admin_in? @roster
  end

  def set_current_user
    if session.key? :user_id
      @current_user = User.find_by id: session[:user_id]
    else
      @current_user = User.find_by spire: request.env['fcIdNumber']
      if @current_user.present?
        session[:user_id] = @current_user.id
      else
        redirect_to unauthenticated_session_path
      end
    end
  end

  # If there's one specified, go to that.
  # Otherwise, go to the first roster of which the current user is a member.
  # Finally, just go to the first roster (if they're a member of none).
  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_roster
    @roster = Roster.find_by(id: params[:roster_id])
    @roster ||= @current_user.rosters.first
    @roster ||= Roster.first
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def check_primary_account
    return if request.env['UMAPrimaryAccount'] == request.env['uid']

    @primary_account = request.env['UMAPrimaryAccount']
    @uid = request.env['uid']
    render 'sessions/subsidiary', status: :unauthorized
  end
end

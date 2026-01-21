# frozen_string_literal: true

require 'assignments_ics'

class AssignmentsController < ApplicationController
  before_action :find_assignment, only: %i[destroy edit update]
  before_action :set_roster_users, only: %i[edit new create update]
  before_action :allow_calendar_token_access, only: :feed
  skip_verify_authorized! only: [:feed]

  def index
    authorize!
    respond_to do |format|
      format.html { index_html }
      format.ics { render_ics_feed }
      format.json { index_json }
      format.csv { index_csv }
    end
  end

  def new
    authorize!
    @start_date = Date.parse params.require(:date)
    @end_date = @start_date + 6.days
    @assignment = Assignment.new
  end

  def edit
    authorize!
  end

  def create
    @assignment = @roster.assignments.new assignment_params
    authorize! @assignment
    if @assignment.save
      confirm_change(@assignment)
      @assignment.notify :owner, of: :new_assignment, by: Current.user
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  def update
    @assignment.assign_attributes assignment_params
    authorize! @assignment
    if @assignment.save
      confirm_change(@assignment)
      notify_appropriate_users
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @assignment
    @assignment.notify :owner, of: :deleted_assignment, by: Current.user
    @assignment.destroy
    confirm_change(@assignment)
    redirect_to roster_assignments_path(@roster)
  end

  def feed
    roster = params[:roster].titleize.downcase
    @roster = Roster.where('lower(name) = ?', roster).first
    authorize! context: { roster: @roster }
    render_ics_feed
  rescue ActionPolicy::Unauthorized
    head :forbidden
  end

  private

  def assignment_params
    params.expect assignment: %i[start_date end_date user_id]
  end

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require(:id))
    @previous_owner = @assignment.user
  end

  def set_roster_users
    @users = @roster.users.active.order :last_name
  end

  def allow_calendar_token_access
    Current.user ||= User.find_by(calendar_access_token: params[:token])
  end

  def index_html
    @assignments = Current.user.assignments.in(@roster).upcoming.order :start_date
    @current_assignment = @roster.assignments.current
    @fallback_user = @roster.fallback_user
  end

  def index_json
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    @assignments = @roster.assignments.between(start_date, end_date)
    render layout: false
  end

  def index_csv
    @roster = Roster.preload(assignments: :user).friendly.find(params[:roster_id])
    render csv: @roster.assignment_csv, filename: @roster.name
  end

  # If the user's being changed, we effectively inform of the change
  # by telling the previous owner they're not responsible anymore,
  # and telling the new owner that they're newly responsible now.
  def notify_appropriate_users
    if @assignment.user == @previous_owner
      @assignment.notify :owner, of: :changed_assignment, by: Current.user
    else
      @assignment.notify :owner, of: :new_assignment, by: Current.user
      @assignment.notify @previous_owner, of: :deleted_assignment, by: Current.user
    end
  end

  def render_ics_feed
    ics = AssignmentsIcs.new(@roster.assignments)
    render plain: ics.output, content_type: 'text/calendar'
  end
end

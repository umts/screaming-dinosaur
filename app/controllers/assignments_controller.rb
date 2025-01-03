# frozen_string_literal: true

require 'assignments_ics'

class AssignmentsController < ApplicationController
  before_action :find_assignment, only: %i[destroy edit update]
  before_action :set_roster_users, only: %i[edit new generate_rotation rotation_generator update]
  before_action :require_admin_in_roster, only: %i[generate_rotation rotation_generator
                                                   generate_by_weekday generate_by_weekday_submit]
  skip_before_action :set_current_user, :set_roster, only: :feed

  def index
    respond_to do |format|
      format.html { index_html }
      format.ics { render_ics_feed }
      format.json { index_json }
      format.csv do
        @roster = Roster.preload(assignments: :user).find(params[:roster_id])
        render csv: @roster.assignment_csv, filename: @roster.name
      end
    end
  end

  def new
    @start_date = Date.parse params.require(:date)
    @end_date = @start_date + 6.days
    @assignment = Assignment.new
  end

  def edit; end

  def generate_rotation
    @start_date = Date.parse params.require(:start_date)
    end_date = Date.parse params.require(:end_date)
    user_ids = params.require :user_ids
    start_user = params.require :starting_user_id
    if end_date.before? @start_date
      flash.now[:errors] = t('.end_before_start')
      render :rotation_generator, status: :unprocessable_entity and return
    end
    unless user_ids.include? start_user
      flash.now[:errors] = t('.start_not_in')
      render :rotation_generator, status: :unprocessable_entity and return
    end
    @roster.generate_assignments(user_ids, @start_date,
                                 end_date, start_user).each do |assignment|
      assignment.notify :owner, of: :new_assignment, by: Current.user
    end
    flash[:message] = 'Rotation has been generated.'
    redirect_to roster_assignments_path(@roster, date: @start_date)
  end

  def generate_by_weekday
    @generator = Assignment::WeekdayGenerator.new roster_id: @roster.id
  end

  def generate_by_weekday_submit
    @generator = Assignment::WeekdayGenerator.new(roster_id: @roster.id,
                                                  **generate_by_weekday_params)
    if @generator.generate
      flash[:message] = t('.success')
      redirect_to roster_assignments_path(@roster, date: @generator.start_date)
    else
      flash.now[:errors] = @generator.errors.full_messages.to_sentence
      render :generate_by_weekday, status: :unprocessable_entity
    end
  end

  def create
    ass_params = params.require(:assignment)
                       .permit :start_date, :end_date,
                               :user_id, :roster_id
    assignment = Assignment.new ass_params
    require_taking_ownership(error_template: :new) or return

    if assignment.save
      confirm_change(assignment)
      assignment.notify :owner, of: :new_assignment, by: Current.user
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = assignment.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    ass_params = params.require(:assignment)
                       .permit :start_date, :end_date, :user_id
    require_taking_ownership(error_template: :edit) or return

    @previous_owner = @assignment.user
    if @assignment.update ass_params
      confirm_change(@assignment)
      notify_appropriate_users
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def rotation_generator
    @start_date = @roster.next_rotation_start_date
  end

  def destroy
    if Current.user.admin_in?(@roster)
      @assignment.notify :owner, of: :deleted_assignment, by: Current.user
      @assignment.destroy
      confirm_change(@assignment)
      redirect_to roster_assignments_path(@roster)
    else
      flash[:errors] = t('.not_an_admin')
      redirect_to edit_roster_assignment_path(@roster, @assignment)
    end
  end

  def feed
    user = User.find_by(calendar_access_token: params[:token])
    roster = params[:roster].titleize.downcase
    @roster = Roster.where('lower(name) = ?', roster).first
    if user.nil?
      render file: 'public/404.html', layout: false, status: :not_found
    elsif params[:format] == 'ics' && user.rosters.include?(@roster)
      render_ics_feed
    else
      render file: 'public/401.html', layout: false, status: :unauthorized
    end
  end

  private

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require(:id))
  end

  def set_roster_users
    @users = @roster.users.active.order :last_name
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

  def require_taking_ownership(error_template: nil)
    return true if Current.user.admin_in?(@roster) || taking_ownership?

    flash.now[:errors] = t('.not_an_admin')
    render error_template, status: :unprocessable_entity
    false
  end

  def taking_ownership?
    new_user_id = params.require(:assignment).require(:user_id)
    new_user_id == Current.user&.id.to_s
  end

  def generate_by_weekday_params
    params.fetch(:assignment_weekday_generator, {}).permit!
  end
end

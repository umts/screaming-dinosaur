# frozen_string_literal: true

require 'assignments_ics'

class AssignmentsController < ApplicationController
  before_action :find_assignment, only: %i[destroy edit update]
  before_action :set_roster_users, only: %i[edit new create update]
  skip_before_action :set_current_user, :set_roster, only: :feed

  def index
    respond_to do |format|
      format.html { index_html }
      format.ics { render_ics_feed }
      format.json { index_json }
      format.csv do
        @roster = Roster.preload(assignments: :user).friendly.find(params[:roster_id])
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

  def create
    @assignment = Assignment.new assignment_params
    require_taking_ownership(error_template: :new) or return

    if @assignment.save
      confirm_change(@assignment)
      @assignment.notify :owner, of: :new_assignment, by: Current.user
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    require_taking_ownership(error_template: :edit) or return

    @previous_owner = @assignment.user
    if @assignment.update assignment_params.except(:roster_id)
      confirm_change(@assignment)
      notify_appropriate_users
      redirect_to roster_assignments_path(@roster)
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
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

  def assignment_params
    params.expect assignment: %i[start_date end_date user_id roster_id]
  end

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

  # rubocop:disable Naming/PredicateMethod
  def require_taking_ownership(error_template: nil)
    return true if Current.user.admin_in?(@roster) || taking_ownership?

    flash.now[:errors] = t('.not_an_admin')
    render error_template, status: :unprocessable_entity
    false
  end
  # rubocop:enable Naming/PredicateMethod

  def taking_ownership?
    new_user_id = params.require(:assignment).require(:user_id)
    new_user_id == Current.user&.id.to_s
  end
end

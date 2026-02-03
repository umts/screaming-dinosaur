# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :find_assignment, only: %i[destroy edit update]
  before_action :set_roster_users, only: %i[edit new create update]

  def index
    authorize!
    respond_to do |format|
      format.html { index_html }
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
      flash_success_for(@assignment, undoable: true)
      redirect_to roster_assignments_path(@roster)
    else
      flash_errors_now_for(@assignment)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @assignment.assign_attributes assignment_params
    authorize! @assignment
    if @assignment.save
      flash_success_for(@assignment, undoable: true)
      redirect_to roster_assignments_path(@roster)
    else
      flash_errors_now_for(@assignment)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @assignment
    @assignment.destroy
    flash_success_for(@assignment, undoable: true)
    redirect_to roster_assignments_path(@roster)
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
end

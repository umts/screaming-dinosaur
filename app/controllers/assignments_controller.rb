class AssignmentsController < ApplicationController
  before_action :find_assignment, only: [:destroy, :edit, :update]

  def create
    assignment_params = params.require(:assignment)
                              .permit :start_date, :end_date,
                                      :user_id, :roster_id
    assignment = Assignment.new assignment_params
    if assignment.save
      confirm_change(assignment)
      redirect_to roster_assignments_path(@roster, date: assignment.start_date)
    else report_errors(assignment)
    end
  end

  def destroy
    @assignment.destroy
    confirm_change(@assignment)
    redirect_to roster_assignments_path(@roster)
  end

  def edit
    @users = @roster.users.order :last_name
  end

  def generate_rotation
    start_date = Date.parse(params.require :start_date)
    end_date = Date.parse(params.require :end_date)
    user_ids = params.require :user_ids
    start_user = params.require :starting_user_id
    @roster.generate_assignments user_ids, start_date, end_date, start_user
    # TODO: undo
    flash[:message] = 'Rotation has been generated.'
    redirect_to roster_assignments_path(@roster, date: start_date)
  end

  # rubocop:disable Metrics/AbcSize, MethodLength

  def index
    @month_date = if params[:date].present?
                    Date.parse params[:date]
                  else Date.today
                  end.beginning_of_month
    start_date = @month_date.beginning_of_week(:sunday)
    end_date = @month_date.end_of_month.end_of_week(:sunday)
    @weeks = (start_date..end_date).each_slice(7)
    @assignments = @current_user.assignments.in(@roster)
                                .upcoming
                                .order :start_date
    @current_assignment = @roster.assignments.current
    @switchover_hour = CONFIG[:switchover_hour]
    @fallback_user = @roster.fallback_user
  end

  # rubocop:enable Metrics/AbcSize, MethodLength

  def new
    @start_date = Date.parse(params.require :date)
    @end_date = @start_date + 6.days
    @users = @roster.users.order :last_name
  end

  def rotation_generator
    @users = User.order :last_name
    @start_date = Assignment.next_rotation_start_date
  end

  def update
    assignment_params = params.require(:assignment)
                              .permit :start_date, :end_date, :user_id
    if @assignment.update assignment_params
      confirm_change(@assignment)
      redirect_to roster_assignments_path(@roster, date: @assignment.start_date)
    else report_errors(@assignment)
    end
  end

  private

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require :id)
  end
end

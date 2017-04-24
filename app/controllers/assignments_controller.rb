class AssignmentsController < ApplicationController
  before_action :find_assignment, only: [:destroy, :edit, :update]
  before_action :require_admin_in_roster, only: %i(generate_rotation
                                                   rotation_generator)

  def create
    ass_params = params.require(:assignment)
                       .permit :start_date, :end_date,
                               :user_id, :roster_id
    assignment = Assignment.new ass_params
    unless @current_user.admin_in?(@roster) || taking_ownership?(ass_params)
      require_taking_ownership and return
    end
    if assignment.save
      confirm_change(assignment)
      assignment.notify_owner of: :create, by: @current_user
      redirect_to roster_assignments_path(@roster, date: assignment.start_date)
    else report_errors(assignment)
    end
  end

  def destroy
    # TODO: should anyone be able to destroy any assignment?
    assignment.notify_owner of: :destroy, by: @current_user
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
    @roster.generate_assignments(user_ids, start_date,
                                 end_date, start_user).each do |assignment|
      assignment.notify_owner of: :create, by: @current_user
    end
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
    ass_params = params.require(:assignment)
                       .permit :start_date, :end_date, :user_id
    unless @current_user.admin_in?(@roster) || taking_ownership?(ass_params)
      require_taking_ownership and return
    end
    if @assignment.update ass_params
      confirm_change(@assignment)
      @assignment.notify_owner of: :update, by: @current_user
      redirect_to roster_assignments_path(@roster, date: @assignment.start_date)
    else report_errors(@assignment)
    end
  end

  private

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require :id)
  end

  def require_taking_ownership
    flash[:errors] = [<<-TEXT]
      You may only edit or create assignments such that you become on call.
      The intended new owner of this assignment must take it themselves.
      Or, a roster administrator can perform this change for you.
    TEXT
    redirect_to :back
  end

  def taking_ownership?(assignment_params)
    assignment_params.require(:user_id) == @current_user.id.to_s
  end
end

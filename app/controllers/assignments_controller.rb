class AssignmentsController < ApplicationController
  before_action :find_assignment, only: [:destroy, :edit, :update]
  before_action :find_rotation

  def create
    assignment_params = params.require(:assignment)
                              .permit :start_date, :end_date,
                                      :user_id, :rotation_id
    assignment = Assignment.new assignment_params
    if assignment.save
      flash[:message] = 'Assignment has been created.'
      redirect_to assignments_path(date: assignment.start_date)
    else
      flash[:errors] = assignment.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @assignment.destroy
    flash[:message] = 'Assignment has been deleted.'
    redirect_to assignments_path
  end

  def edit
    @users = @rotation.users.order :last_name
  end

  def generate_rotation
    start_date = Date.parse(params.require :start_date)
    end_date = Date.parse(params.require :end_date)
    user_ids = params.require :user_ids
    start_user = params.require :starting_user_id
    @rotation.generate_assignments user_ids, start_date, end_date, start_user
    flash[:message] = 'Rotation has been generated.'
    redirect_to rotation_assignments_path(@rotation, date: start_date)
  end

  def index
    @month_date = if params[:date].present?
                    Date.parse params[:date]
                  else Date.today
                  end.beginning_of_month
    start_date = @month_date.beginning_of_week(:sunday)
    end_date = @month_date.end_of_month.end_of_week(:sunday)
    @weeks = (start_date..end_date).each_slice(7)
    @assignments = @current_user.assignments.in(@rotation)
                                            .upcoming
                                            .order :start_date
    @current_assignment = Assignment.current_for(@rotation)
    @switchover_hour = CONFIG[:switchover_hour]
    @fallback_user = @rotation.fallback_user
  end

  def new
    @start_date = Date.parse(params.require :date)
    @end_date = @start_date + 6.days
    @users = User.order :last_name
  end

  def rotation_generator
    @users = User.order :last_name
    @start_date = Assignment.next_rotation_start_date
  end

  def update
    assignment_params = params.require(:assignment)
                              .permit :start_date, :end_date, :user_id
    if @assignment.update assignment_params
      flash[:message] = 'Assignment has been updated.'
      redirect_to rotation_assignments_path(@rotation, date: @assignment.start_date)
    else
      flash[:errors] = @assignment.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require :id)
  end

  # If there's one specified, go to that.
  # Otherwise, go to the first rotation of which the current user is a member.
  # Finally, just go to the first rotation (if they're a member of none).
  def find_rotation
    @rotation = Rotation.find_by(id: params[:rotation_id])
    @rotation ||= @current_user.rotations.first
    @rotation ||= Rotation.first
  end
end

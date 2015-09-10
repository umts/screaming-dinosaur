class AssignmentsController < ApplicationController
  before_action :find_assignment, only: [:destroy, :edit, :update]

  def create
    assignment_params = params.require(:assignment)
                        .permit :start_date, :end_date, :user_id
    assignment = Assignment.new assignment_params
    if assignment.save
      flash[:message] = 'Assignment has been updated.'
      redirect_to assignments_path
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
    @users = User.order :last_name
  end

  def index
    @date = if params[:date].present?
              Date.parse params[:date]
            else Date.today
            end.beginning_of_week :sunday
    @week = @date..(@date + 6.days)
  end

  def new
    @start_date = Date.parse(params.require :date)
    @end_date = @start_date + 6.days
    @users = User.order :last_name
  end

  def update
    assignment_params = params.require(:assignment).permit(:start_date,
                                                           :end_date,
                                                           :user_id)
    if @assignment.update assignment_params
      flash[:message] = 'Assignment has been updated.'
      redirect_to assignments_path
    else
      flash[:errors] = @assignment.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_assignment
    @assignment = Assignment.includes(:user).find(params.require :id)
  end
end

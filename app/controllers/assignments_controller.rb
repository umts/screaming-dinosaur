# frozen_string_literal: true

class AssignmentsController < ApplicationController
  include Rosterable

  before_action :find_assignment, only: %i[edit update destroy]
  before_action :initialize_assignment, only: %i[new create]

  def index
    authorize!
    respond_to do |format|
      format.json do
        @assignments = assignment_range if params[:start_datetime] && params[:end_datetime]
      end
      format.csv do
        render csv: roster.assignment_csv, filename: roster.name
      end
    end
  end

  def new
    authorize! @assignment
  end

  def edit
    authorize! @assignment
  end

  def create
    @assignment.assign_attributes assignment_params
    authorize! @assignment
    if @assignment.save
      flash_success_for(@assignment, undoable: true)
      redirect_to roster_path(@assignment.roster)
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
      redirect_to roster_path(@assignment.roster)
    else
      flash_errors_now_for(@assignment)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @assignment
    @assignment.destroy
    flash_success_for(@assignment, undoable: true)
    redirect_to roster_path(@assignment.roster)
  end

  private

  def find_assignment
    @assignment = Assignment.find(params[:id])
  end

  def initialize_assignment
    @assignment = roster.assignments.new
    return if params[:date].blank?

    @assignment.end_datetime = params[:date].to_date + 6.days
  end

  def assignment_params
    params.expect assignment: %i[start_datetime end_datetime user_id]
  end

  def assignment_range
    return unless params[:start_datetime] && params[:end_datetime]

    roster.assignments.between(Date.parse(params[:start_datetime]),
                               Date.parse(params[:end_datetime]))
  end
end

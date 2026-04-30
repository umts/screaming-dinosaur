# frozen_string_literal: true

class AssignmentsController < ApplicationController
  include Rosterable

  before_action :find_assignment, only: %i[edit update destroy]
  before_action :initialize_assignment, only: %i[new create]

  def index
    authorize!
    respond_to do |format|
      format.json { index_json }
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
  end

  def assignment_params
    params.expect assignment: %i[end_datetime user_id]
  end

  def index_json
    @assignments = roster.assignments.with_start_datetimes.preload(:user)
    return unless params[:start_datetime].present? && params[:end_datetime].present?

    @assignments = @assignments.where(
      start_datetime: nil..Date.parse(params[:end_datetime]).at_end_of_day,
      end_datetime: Date.parse(params[:start_datetime]).at_beginning_of_day..nil
    )
  end
end

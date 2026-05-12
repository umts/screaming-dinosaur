# frozen_string_literal: true

class RostersController < ApplicationController
  before_action :find_roster, only: %i[show edit update destroy]
  before_action :initialize_roster, only: %i[new create]

  def index
    authorize!
    @rosters = authorized_scope(Roster.includes(:fallback_user, current_assignment: :user)).page(params[:page])
  end

  def show
    respond_to do |format|
      format.html { show_html }
      format.json { show_json }
    end
  end

  def new
    authorize! @roster
  end

  def edit
    authorize! @roster
  end

  def create
    @roster.assign_attributes roster_params
    authorize! @roster
    if @roster.save
      flash_success_for(@roster)
      redirect_to edit_roster_path(@roster)
    else
      flash_errors_now_for(@roster)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @roster.assign_attributes roster_params
    authorize! @roster
    if @roster.save
      flash_success_for(@roster, undoable: true)
      redirect_to edit_roster_path(@roster)
    else
      flash_errors_now_for(@roster)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @roster
    @roster.destroy
    flash_success_for(@roster)
    redirect_to rosters_path
  end

  private

  def find_roster
    @roster = Roster.friendly.find(params.expect(:id))
  end

  def initialize_roster
    @roster = Roster.new
    @roster.memberships.build user: Current.user, admin: true
  end

  def roster_params
    params.expect roster: %i[name phone fallback_user_id switchover_time]
  end

  def show_html
    authorize! @roster
    @your_assignments = @roster.assignments.with_start_datetimes
                               .ending_after(Time.current).where(user: Current.user)
                               .order(end_datetime: :asc)
  end

  def show_json
    authorize! @roster, context: { api_key: request.headers['Authorization']&.split&.last }
    @upcoming = @roster.assignments.ending_after(Time.current).order(end_datetime: :asc)
  end
end

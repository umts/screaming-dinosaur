# frozen_string_literal: true

class RostersController < ApplicationController
  skip_before_action :set_roster
  before_action :find_roster, only: %i[show edit update destroy setup]
  before_action :initialize_roster, only: %i[new create]

  def index
    authorize!
    @rosters = Roster.all.select { |roster| allowed_to?(:show?, roster) }
  end

  def show
    authorize! @roster, context: { api_key: params[:api_key] }
    @upcoming = @roster.assignments.upcoming.order(:start_date)
    respond_to do |format|
      format.json { render layout: false }
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
      # Current user becomes admin in new roster
      @roster.memberships.create(user: Current.user, admin: true)
      flash_success_for(@roster, undoable: true)
      redirect_to rosters_path
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
      redirect_to rosters_path
    else
      flash_errors_now_for(@roster)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @roster
    @roster.destroy
    flash_success_for(@roster, undoable: true)
    redirect_to rosters_path
  end

  def assignments
    authorize!
    redirect_to roster_assignments_path(@roster)
  end

  def setup
    authorize! @roster
  end

  private

  def find_roster
    @roster = Roster.friendly.find params.require(:id)
  end

  def initialize_roster
    @roster = Roster.new
  end

  def roster_params
    params.expect(roster: %i[name phone fallback_user_id switchover_time])
  end
end

# frozen_string_literal: true

class RostersController < ApplicationController
  before_action :find_roster, only: %i[show edit update destroy setup]
  before_action :initialize_roster, only: %i[new create]

  def index
    authorize!
    @rosters = authorized_scope Roster.all
  end

  def show
    authorize! @roster, context: { api_key: params[:api_key] }
    respond_to do |format|
      format.html do
        @your_assignments = @roster.assignments.upcoming.joins(:user).where(user: Current.user).order(start_date: :asc)
      end
      format.json do
        @upcoming = @roster.assignments.upcoming.order(:start_date)
      end
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
      redirect_to edit_roster_path(@roster)
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

  def setup
    authorize! @roster
  end

  private

  def find_roster
    @roster = Roster.friendly.find params[:id]
  end

  def initialize_roster
    @roster = Roster.new
    @roster.memberships.build user: Current.user, admin: true
  end

  def roster_params
    params.expect roster: %i[name phone fallback_user_id switchover_time]
  end
end

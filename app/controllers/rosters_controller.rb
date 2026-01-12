# frozen_string_literal: true

class RostersController < ApplicationController
  api_accessible only: :show

  before_action :find_roster, only: %i[destroy edit setup show update]
  # before_action :require_admin, except: %i[assignments show]
  # before_action :require_admin_in_roster, only: %i[destroy edit setup update]

  def index
    authorize!
    @rosters = Roster.all
  end

  def show
    authorize! @roster, context: { api_key: params[:api_key] }
    @upcoming = @roster.assignments.upcoming.order(:start_date)
    respond_to do |format|
      format.json { render layout: false }
    end
  end

  def new
    authorize!
  end

  def edit
    authorize! @roster
  end

  def create
    authorize!
    @roster = Roster.new roster_params
    if @roster.save
      # Current user becomes admin in new roster
      @roster.memberships.create(user: Current.user, admin: true)
      confirm_change(@roster)
      redirect_to rosters_path
    else
      flash.now[:errors] = @roster.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize! @roster
    if @roster.update roster_params
      confirm_change(@roster)
      redirect_to rosters_path
    else
      flash.now[:errors] = @roster.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @roster
    @roster.destroy
    confirm_change(@roster, 'Roster and any assignments have been deleted.')
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

  def roster_params
    params.expect(roster: %i[name phone fallback_user_id switchover_time]).tap do |p|
      time = Time.zone.parse p.delete(:switchover_time).to_s
      p[:switchover] = time && ((time.hour * 60) + time.min)
    end
  end
end

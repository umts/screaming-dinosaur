# frozen_string_literal: true

class RostersController < ApplicationController
  api_accessible only: :show

  before_action :find_roster, only: %i[destroy edit setup show update]
  before_action :require_admin, except: %i[assignments show]
  before_action :require_admin_in_roster, only: %i[destroy edit setup update]

  def assignments
    redirect_to roster_assignments_path(@roster)
  end

  def index
    @rosters = Roster.all
  end

  def show
    respond_to do |format|
      format.json { render layout: false }
    end
  end

  def edit
    @users = @roster.users
  end

  def create
    roster = Roster.new roster_params
    # Current user becomes admin in new roster
    roster.users << Current.user
    roster.memberships.first.update admin: true
    if roster.save
      confirm_change(roster)
      redirect_to rosters_path
    else
      report_errors(roster, fallback_location: rosters_path)
    end
  end

  def update
    if @roster.update roster_params
      confirm_change(@roster)
      redirect_to rosters_path
    else
      report_errors(@roster, fallback_location: rosters_path)
    end
  end

  def setup; end

  def destroy
    @roster.destroy
    confirm_change(@roster, 'Roster and any assignments have been deleted.')
    redirect_to rosters_path
  end

  private

  def find_roster
    @roster = Roster.friendly.find params.require(:id)
  end

  def roster_params
    params.require(:roster).permit(:name, :phone, :fallback_user_id, :switchover_time).tap do |p|
      time = Time.zone.parse p.delete(:switchover_time).to_s
      p[:switchover] = time && ((time.hour * 60) + time.min)
    end
  end
end

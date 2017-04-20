class RostersController < ApplicationController
  # The default scaffold method, not the generic one
  # we wrote in ApplicationController.
  before_action :find_roster, only: %i(destroy edit update)
  before_action :require_admin_in_roster, only: %i(destroy edit update)
  before_action :require_admin, except: %i(destroy edit update)

  def create
    roster_params = params.require(:roster).permit(:name)
    roster = Roster.new roster_params
    # Current user becomes admin in new roster
    roster.users << @current_user
    roster.memberships.first.update admin: true
    if roster.save
      confirm_change(roster)
      redirect_to rosters_path
    else report_errors(roster)
    end
  end

  def destroy
    @roster.destroy
    confirm_change(@roster, 'Roster and any assignments have been deleted.')
    redirect_to rosters_path
  end

  def edit
    @users = @roster.users
  end

  def index
    @rosters = Roster.all
  end

  def new
  end

  def update
    roster_params = params.require(:roster).permit!
    if @roster.update roster_params
      confirm_change(@roster)
      redirect_to rosters_path
    else report_errors(@roster)
    end
  end

  private

  def find_roster
    @roster = Roster.find(params.require :id)
  end
end

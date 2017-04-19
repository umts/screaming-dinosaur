class RostersController < ApplicationController
  # The default scaffold method, not the generic one
  # we wrote in ApplicationController.
  before_action :find_roster, only: [:destroy, :edit, :update]
  before_action :validate_admin_in_roster, only: %i(destroy edit update)

  def create
    roster_params = params.require(:roster).permit(:name)
    roster = Roster.new roster_params
    if roster.save
      confirm_change(roster)
      redirect_to rosters_path
    else
      flash[:errors] = roster.errors.full_messages
      redirect_to :back
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
    else
      flash[:errors] = @roster.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_roster
    @roster = Roster.find(params.require :id)
  end

  def validate_admin_in_roster
    # ... and return is correct here
    # rubocop:disable Style/AndOr
    head :unauthorized and return unless @current_user.admin_in? @roster
    # rubocop:enable Style/AndOr
  end
end

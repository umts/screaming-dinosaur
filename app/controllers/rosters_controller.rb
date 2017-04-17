class RostersController < ApplicationController
  # The default scaffold method, not the generic one
  # we wrote in ApplicationController.
  before_action :find_roster, only: [:destroy, :edit, :update]
  before_action :validate_admin_in_roster, only: %i(destroy edit update)

  def create
    roster_params = params.require(:roster).permit(:name)
    roster = Roster.new roster_params
    if roster.save
      flash[:message] = 'Roster has been created.'
      redirect_to rosters_path
    else
      flash[:errors] = roster.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @roster.destroy
    flash[:message] = 'Roster and any assignments have been deleted.'
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
      flash[:message] = 'Roster has been updated.'
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
    head :unauthorized and return unless @current_user.admin_in? @roster
  end
end

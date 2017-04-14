class RostersController < ApplicationController
  before_action :find_roster, only: [:destroy, :edit, :update]

  def create
    roster_params = params.require(:roster).permit(:name)
    roster = Roster.new roster_params
    if roster.save
      flash[:message] = 'roster has been created.'
      redirect_to rosters_path
    else
      flash[:errors] = roster.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @roster.destroy
    flash[:message] = 'roster and any assignments have been deleted.'
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
      flash[:message] = 'roster has been updated.'
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

end

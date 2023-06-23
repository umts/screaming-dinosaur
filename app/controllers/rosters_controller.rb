# frozen_string_literal: true

class RostersController < ApplicationController
  # The default scaffold method, not the generic one
  # we wrote in ApplicationController.
  before_action :find_roster, only: %i[destroy edit setup update]
  before_action :require_admin, except: %i[assignments]
  before_action :require_admin_in_roster, only: %i[destroy edit setup update]

  def assignments
    redirect_to roster_assignments_path(@roster)
  end

  def index
    @rosters = Roster.all
  end

  def edit
    @users = @roster.users
  end

  def create
    roster_params = params.require(:roster).permit(:name)
    roster = Roster.new roster_params
    # Current user becomes admin in new roster
    roster.users << @current_user
    roster.memberships.first.update admin: true
    if roster.save
      confirm_change(roster)
      redirect_to rosters_path
    else
      flash.now[:errors] = roster.errors.full_messages
      render 'new'
    end
  end

  def update
    roster_params = params.require(:roster).permit(:name, :fallback_user_id)
    if @roster.update roster_params
      confirm_change(@roster)
      redirect_to rosters_path
    else
      flash.now[:errors] = @roster.errors.full_messages
      render 'edit'
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
    @roster = Roster.find params.require(:id)
  end
end

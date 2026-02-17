# frozen_string_literal: true

class MembershipsController < ApplicationController
  include Rosterable

  before_action :find_membership, only: %i[update destroy]
  before_action :initialize_membership, only: :create

  def index
    authorize!
    @memberships = roster.memberships.joins(:user).order('users.first_name', 'users.last_name')
  end

  def create
    @membership.assign_attributes membership_params
    authorize! @membership
    if @membership.save
      flash_success_for(@membership, undoable: true)
    else
      flash_errors_for(@membership)
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  def update
    @membership.assign_attributes membership_params
    authorize! @membership
    if @membership.save
      flash_success_for(@membership, undoable: true)
    else
      flash_errors_for(@membership)
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  def destroy
    authorize! @membership
    if @membership.destroy
      flash_success_for(@membership, undoable: true)
    else
      flash_errors_for(@membership)
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  private

  def find_membership
    @membership = Membership.find(params[:id])
  end

  def initialize_membership
    @membership = roster.memberships.new
  end

  def membership_params
    params.expect membership: %i[user_id admin]
  end
end

# frozen_string_literal: true

class MembershipsController < ApplicationController
  skip_before_action :set_roster
  before_action :initialize_membership, only: :create
  before_action :find_membership, only: %i[update destroy]

  def index
    @roster = Roster.friendly.find(params[:roster_id])
    authorize! context: { roster: @roster }
    @active = !params[:active]
    @memberships = @roster.memberships.joins(:user).where(user: { active: @active ? true : [nil, false] })
    @other_users = User.order(:last_name) - @roster.users
  end

  def create
    @membership.assign_attributes(membership_params)
    authorize! @membership
    if @membership.save
      confirm_change(@membership, "Added #{@membership.user.full_name} to roster.")
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  def update
    @membership.assign_attributes(membership_params)
    authorize! @membership
    if @membership.save
      confirm_change(@membership, "Updated #{@membership.user.full_name}.")
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  def destroy
    authorize! @membership
    if @membership.destroy
      confirm_change @membership
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_memberships_path(@membership.roster)
  end

  private

  def initialize_membership
    @membership = Roster.friendly.find(params[:roster_id]).memberships.new
  end

  def find_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.expect(membership: %i[user_id admin])
  end
end

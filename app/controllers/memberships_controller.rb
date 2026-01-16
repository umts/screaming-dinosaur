# frozen_string_literal: true

class MembershipsController < ApplicationController
  before_action :set_roster
  before_action :set_membership, except: :create

  def create
    @membership = Membership.new(user_id: params[:user_id], roster: @roster)
    authorize! @membership
    if @membership.save
      confirm_change(@membership.user, "Added #{@membership.user.full_name} to roster.")
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_users_path(@roster)
  end

  def update
    authorize! @membership
    if @membership.update(admin: params[:admin])
      if @membership.admin
        confirm_change(@membership.user, "Made #{@membership.user.full_name} a roster admin.")
      else
        confirm_change(@membership.user, "Removed #{@membership.user.full_name} as a roster admin.")
      end
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_users_path(@roster)
  end

  def destroy
    authorize! @membership
    if @membership.admin && @roster.admins.one?
      flash[:error] = "Cannot remove #{@membership.user.full_name}, they are the last admin of roster"
      redirect_to roster_users_path(@roster)
    elsif @membership.destroy
      confirm_change(@membership.user)
    else
      flash[:error] = @membership.errors.full_messages
    end
    redirect_to roster_users_path(@roster)
  end

  private

  def set_roster
    @roster = Roster.friendly.find(params[:roster_id], allow_nil: true)
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end
end

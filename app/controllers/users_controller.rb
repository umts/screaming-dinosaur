# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :find_user, except: %i(create index new)
  before_action :require_admin_in_roster_or_self, only: %i(edit update)
  before_action :require_admin_in_roster, except: %i(edit update)

  WHITELISTED_ATTRIBUTES = [:first_name, :last_name, :spire, :email,
                            :phone, :reminders_enabled,
                            :change_notifications_enabled,
                            rosters: [], membership: [:admin]].freeze

  def create
    user_params = params.require(:user).permit(*WHITELISTED_ATTRIBUTES)
    user = User.new user_params
    user.rosters << @roster
    if user.save
      confirm_change(user)
      redirect_to roster_users_path(@roster)
    else report_errors(user)
    end
  end

  def destroy
    if @user.destroy
      confirm_change(@user)
      redirect_to roster_users_path
    else report_errors(@user)
    end
  end

  def index
    @users = @roster.users
    @other_users = User.all - @users
    @fallback = @roster.fallback_user
  end

  def transfer
    @user.rosters += [@roster]
    if @user.save
      confirm_change(@user, "Added #{@user.full_name} to roster.")
      redirect_to roster_users_path(@roster)
    else report_errors(@user)
    end
  end

  def update
    user_params = params.require(:user).permit(*WHITELISTED_ATTRIBUTES)
    membership_params = user_params[:membership]
    user_params = parse_roster_ids(user_params.except :membership)
    if @user.update(user_params) && update_membership(membership_params)
      confirm_change(@user)
      if @current_user.admin_in? @roster
        redirect_to roster_users_path(@roster)
      else redirect_to roster_assignments_path(@roster)
      end
    else report_errors(@user)
    end
  end

  private

  def find_user
    @user = User.find(params.require :id)
  end

  def update_membership(membership_params)
    if membership_params.present? && @current_user.admin_in?(@roster)
      membership = @user.membership_in @roster
      membership.update membership_params
    else true
    end
  end

  def parse_roster_ids(attrs)
    attrs[:rosters] = attrs[:rosters].map do |roster_id|
      Roster.find_by id: roster_id
    end.compact
    attrs
  end

  def require_admin_in_roster_or_self
    return if @current_user == @user || @current_user.admin_in?(@roster)
    # ... and return is correct here
    # rubocop:disable Style/AndOr
    head :unauthorized and return
    # rubocop:enable Style/AndOr
  end
end

class UsersController < ApplicationController
  before_action :find_user, except: %i(create index new)

  def create
    user_params = params.require(:user).permit!
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
    user_params = params.require(:user).permit!
    if @user.update parse_roster_ids(user_params)
      confirm_change(@user)
      redirect_to roster_users_path(@roster)
    else report_errors(@user)
    end
  end

  private

  def find_user
    @user = User.find(params.require :id)
  end

  def parse_roster_ids(attrs)
    attrs[:rosters] = attrs[:rosters].map do |roster_id|
      Roster.find_by id: roster_id
    end.compact
    attrs
  end
end

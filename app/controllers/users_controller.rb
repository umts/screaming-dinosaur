class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :edit, :update]

  def create
    user_params = params.require(:user).permit!
    user = User.new user_params
    user.rosters << @roster
    if user.save
      flash[:message] = 'User has been created.'
      redirect_to roster_users_path(@roster)
    else
      flash[:errors] = user.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @user.destroy
    flash[:message] = 'User has been deleted.'
    redirect_to roster_users_path
  end

  def index
    @users = @roster.users
    @fallback = @roster.fallback_user
  end

  def update
    user_params = params.require(:user).permit!
    if @user.update parse_roster_ids(user_params)
      flash[:message] = 'User has been updated.'
      redirect_to roster_users_path(@roster)
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to :back
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

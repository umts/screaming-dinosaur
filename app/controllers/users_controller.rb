class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :edit, :update]
  before_action :find_rotation

  def create
    user_params = params.require(:user).permit!
    user = User.new user_params
    user.rotations << @rotation
    if user.save
      flash[:message] = 'User has been created.'
      redirect_to rotation_users_path(@rotation)
    else
      flash[:errors] = user.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @user.destroy
    flash[:message] = 'User has been deleted.'
    redirect_to users_path
  end

  def index
    @users = @rotation.users
    @fallback = @rotation.fallback_user
  end

  def update
    user_params = params.require(:user).permit!
    if @user.update user_params
      flash[:message] = 'User has been updated.'
      redirect_to rotation_users_path(@rotation)
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_user
    @user = User.find(params.require :id)
  end

  def find_rotation
    @rotation = Rotation.find(params.require :rotation_id)
  end
end

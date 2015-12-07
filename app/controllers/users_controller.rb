class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :edit, :update]

  def create
    user_params = params.require(:user).permit!
    user = User.new user_params
    if user.save
      flash[:message] = 'User has been created.'
      redirect_to users_path
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

  def edit
  end

  def index
    @users = User.all
    @no_fallback = User.fallback.nil?
  end

  def new
  end

  def update
    user_params = params.require(:user).permit!
    if @user.update user_params
      flash[:message] = 'User has been updated.'
      redirect_to users_path
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to :back
    end
  end

  private

  def find_user
    @user = User.find(params.require :id)
  end
end

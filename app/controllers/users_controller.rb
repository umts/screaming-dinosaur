# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[edit update]
  before_action :initialize_user, only: %i[new create]

  def index
    authorize!
    @users = User.order(active: :desc, first_name: :asc, last_name: :asc)
  end

  def new
    authorize! @user
  end

  def edit
    authorize! @user
  end

  def create
    @user.assign_attributes(user_params)
    authorize! @user
    if @user.save
      flash_success_for(@user)
      redirect_to root_path
    else
      flash_errors_now_for(@user)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @user.assign_attributes(user_params)
    authorize! @user
    if @user.save
      flash_success_for(@user, undoable: true)
      redirect_to edit_user_path(@user)
    else
      flash_errors_now_for(@user)
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_user
    @user = User.find params[:id]
  end

  def initialize_user
    @user = User.new entra_uid: session[:entra_uid],
                     email: session[:email],
                     first_name: session[:first_name],
                     last_name: session[:last_name]
  end

  def user_params
    params.expect user: %i[first_name last_name email phone admin active reminders_enabled change_notifications_enabled]
  end
end

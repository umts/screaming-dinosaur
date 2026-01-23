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
      confirm_change(@user)
      redirect_to users_path
    else
      flash.now[:errors] = @user.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  def update
    @user.assign_attributes(user_params)
    authorize! @user
    if @user.save
      confirm_change(@user)
      redirect_to allowed_to?(:index?, User) ? users_path : root_path
    else
      flash.now[:errors] = @user.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_user
    @user = User.find params[:id]
  end

  def initialize_user
    @user = User.new
  end

  def user_params
    params.expect(user: %i[first_name last_name spire email phone admin active reminders_enabled
                           change_notifications_enabled])
  end
end

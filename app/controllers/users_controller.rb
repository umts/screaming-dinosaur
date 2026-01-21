# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[create index new]

  def index
    authorize!
    @active = !params[:active]
    @users = User.where active: @active
  end

  def new
    authorize!
    @user = User.new
  end

  def edit
    authorize! @user
  end

  def create
    authorize!
    @user = User.new(user_params)
    if @user.save
      confirm_change(@user)
      redirect_to users_path
    else
      flash.now[:errors] = @user.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize! @user
    if @user.update(user_params)
      confirm_change(@user)
      redirect_to update_redirect_path
    else
      flash.now[:errors] = @user.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[first_name last_name spire email phone active reminders_enabled
                           change_notifications_enabled])
  end

  def find_user
    @user = User.find params.require(:id)
  end

  def update_redirect_path
    allowed_to?(:index?) ? users_path : roster_assignments_path(@roster)
  end
end

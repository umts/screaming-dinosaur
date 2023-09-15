# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[create index new]
  before_action :require_admin_in_roster_or_self, only: %i[edit update]
  before_action :require_admin_in_roster, except: %i[edit update]

  WHITELISTED_ATTRIBUTES = [:first_name, :last_name, :spire, :email,
                            :phone, :active, :reminders_enabled,
                            :change_notifications_enabled,
                            { roster_ids: [], membership: [:admin] }].freeze

  def index
    @fallback = @roster.fallback_user
    @active = !params[:active]
    @users = @roster.users.where active: @active
    @other_users = User.all - @roster.users
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    create_user_params = params.require(:user).permit(*WHITELISTED_ATTRIBUTES)
    membership_params = create_user_params[:membership]
    @user = User.new(create_user_params.except(:membership))
    if @user.save && update_membership(membership_params)
      confirm_change(@user)
      redirect_to roster_users_path(@roster)
    else
      flash.now[:errors] = @user.errors.full_messages
      render 'new'
    end
  end

  def update
    membership_params = user_params[:membership]
    if @user.update(user_params.except(:membership)) && update_membership(membership_params)
      confirm_change(@user)
      if @current_user.admin_in? @roster
        redirect_to roster_users_path(@roster)
      else
        redirect_to roster_assignments_path(@roster)
      end
    else
      flash.now[:errors] = @user.errors.full_messages
      render 'edit'
    end
  end

  def transfer
    @user.rosters += [@roster]
    if @user.save
      confirm_change(@user, "Added #{@user.full_name} to roster.")
      redirect_to roster_users_path(@roster)
    else
      report_errors(@user, fallback_location: roster_users_path)
    end
  end

  def destroy
    if @user.destroy
      confirm_change(@user)
      redirect_to roster_users_path
    else
      report_errors(@user, fallback_location: roster_users_path)
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(
      :first_name, :last_name, :spire, :email, :phone, :active, :reminders_enabled,
      :change_notifications_enabled, roster_ids: [], membership: [:admin]
    ).tap do |params|
      given_roster_ids = params[:roster_ids].map(&:to_i)
      params[:roster_ids] = (@user.rosters.map(&:id) || []).then do |roster_ids|
        roster_ids.reject! { |roster_id| !roster_id.in?(given_roster_ids) && @current_user.admin_in?(roster_id) }
        roster_ids | (given_roster_ids & @user.rosters.map(&:id))
      end
    end
  end

  def find_user
    @user = User.find params.require(:id)
  end

  def update_membership(membership_params)
    return true unless membership_params.present? && @current_user.admin_in?(@roster)

    membership = @user.membership_in @roster
    return true if membership.nil?

    return true if membership.update membership_params

    @user.errors.merge! membership.errors
    false
  end

  def require_admin_in_roster_or_self
    return if @current_user == @user || @current_user.admin_in?(@roster)

    render file: 'public/401.html', status: :unauthorized
  end
end

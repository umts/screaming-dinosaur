# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[create index new]
  before_action :require_admin_in_roster_or_self, only: %i[edit update]
  before_action :require_admin_in_roster, except: %i[edit update]

  def index
    @fallback = @roster.fallback_user
    @active = !params[:active]
    @users = @roster.users.where active: @active
    @other_users = User.order(:last_name) - @roster.users
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params.except(:membership))
    membership_params = user_params[:membership]
    if @user.save && update_membership(membership_params)
      confirm_change(@user)
      redirect_to roster_users_path(@roster)
    else
      flash.now[:errors] = @user.errors.full_messages
      render :new
    end
  end

  def update
    membership_params = user_params[:membership]
    if @user.update(user_params.except(:membership)) && update_membership(membership_params)
      confirm_change(@user)
      redirect_to update_redirect_path
    else
      flash.now[:errors] = @user.errors.full_messages
      render :edit
    end
  end

  def transfer
    @user.rosters += [@roster]
    if @user.save
      confirm_change(@user, "Added #{@user.full_name} to roster.")
    else
      flash[:errors] = @user.errors.full_messages
    end
    redirect_to roster_users_path(@roster)
  end

  def destroy
    if @user.destroy
      confirm_change(@user)
    else
      flash[:errors] = @user.errors.full_messages
    end
    redirect_to roster_users_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :spire, :email, :phone, :active, :reminders_enabled,
                                 :change_notifications_enabled, roster_ids: [], membership: [:admin]).tap do |p|
      next if p[:roster_ids].blank?

      p[:roster_ids] = new_roster_ids(p[:roster_ids].map(&:to_i))
    end
  end

  def new_roster_ids(given_roster_ids)
    (@user&.roster_ids || []).then do |roster_ids|
      roster_ids.reject! { |roster_id| !roster_id.in?(given_roster_ids) && Current.user.admin_in?(roster_id) }
      roster_ids | (given_roster_ids & Current.user.memberships.where(admin: true).map(&:roster_id))
    end
  end

  def find_user
    @user = User.find params.require(:id)
  end

  def update_membership(membership_params)
    return true unless membership_params.present? && Current.user.admin_in?(@roster)

    membership = @user.membership_in @roster
    return true if membership.nil?

    return true if membership.update membership_params

    @user.errors.merge! membership.errors
    false
  end

  def update_redirect_path
    Current.user.admin_in?(@roster) ? roster_users_path(@roster) : roster_assignments_path(@roster)
  end

  def require_admin_in_roster_or_self
    return if Current.user == @user || Current.user.admin_in?(@roster)

    render file: 'public/401.html', status: :unauthorized
  end
end

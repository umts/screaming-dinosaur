# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[create index new]

  def index
    authorize! context: { roster: @roster }
    @fallback = @roster.fallback_user
    @users = @roster.users
    @other_users = User.order(:last_name) - @roster.users
  end

  def new
    authorize! context: { roster: @roster }
    @user = User.new
  end

  def edit
    authorize! @user, context: { roster: @roster }
  end

  def create
    authorize! context: { roster: @roster }
    @user = User.new(user_params.except(:membership))
    membership_params = user_params[:membership]
    if @user.save && update_membership(membership_params)
      flash_success_for(@user, undoable: true)
      redirect_to roster_users_path(@roster)
    else
      flash_errors_now_for(@user)
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize! @user, context: { roster: @roster }
    membership_params = user_params[:membership]
    if @user.update(user_params.except(:membership)) && update_membership(membership_params)
      flash_success_for(@user, undoable: true)
      redirect_to update_redirect_path
    else
      flash_errors_now_for(@user)
      render :edit, status: :unprocessable_content
    end
  end

  def transfer
    authorize! context: { roster: @roster }
    @user.rosters += [@roster]
    if @user.save
      flash_success_for(@user)
    else
      flash_errors_for(@user)
    end
    redirect_to roster_users_path(@roster)
  end

  private

  def user_params
    params.expect(user: [:first_name, :last_name, :spire, :email, :phone, :reminders_enabled,
                         :change_notifications_enabled, { roster_ids: [], membership: [:admin] }]).tap do |p|
      next if p[:roster_ids].blank?

      p[:roster_ids] = new_roster_ids(p[:roster_ids].compact_blank.map(&:to_i))
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

  # rubocop:disable Naming/PredicateMethod
  def update_membership(membership_params)
    return true unless membership_params.present? && allowed_to?(:update?, @user, context: { roster: @roster })

    membership = @user.membership_in @roster
    return true if membership.nil?

    return true if membership.update membership_params

    @user.errors.merge! membership.errors
    false
  end
  # rubocop:enable Naming/PredicateMethod

  def update_redirect_path
    allowed_to?(:index?, context: { roster: @roster }) ? roster_users_path(@roster) : roster_assignments_path(@roster)
  end
end

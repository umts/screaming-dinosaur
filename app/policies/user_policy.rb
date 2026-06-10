# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  skip_pre_check :allow_admins, only: %i[create? change_entra_uid?]

  def manage? = false

  def create? = request.session[:entra_uid].present? && user.blank? && no_admin_changes?

  def update? = user == record && no_admin_changes?

  def show_entra_uid? = user&.admin?

  def change_entra_uid? = user&.admin? && record != user

  private

  def no_admin_changes? = record.changes.slice('admin').blank?
end

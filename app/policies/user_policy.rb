# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  skip_pre_check :allow_admins, only: :create?

  def manage? = false

  def create? = request.session[:entra_uid].present? && user.blank? && no_admin_changes?

  def update? = user == record && no_admin_changes?

  private

  def no_admin_changes? = record.changes.slice('admin', 'active').blank?
end

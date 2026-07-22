# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  skip_pre_check :allow_admins, only: %i[create? update? update_access? update_auth?]

  def manage? = false

  def show_auth? = false

  def create?
    request.session[:entra_uid].present? && user.blank? && no_access_changes? &&
      record.entra_uid == request.session[:entra_uid]
  end

  def update?
    return false unless no_access_changes? || allowed_to?(:update_access?, record)
    return false unless no_auth_changes? || allowed_to?(:update_auth?, record)

    user == record || allowed_to?(:manage?, record)
  end

  def update_access? = user&.admin && user != record

  def update_auth? = user&.admin && user != record

  private

  def no_access_changes? = record.changes.slice('admin').blank?

  def no_auth_changes? = record.changes.slice('entra_uid').blank?
end

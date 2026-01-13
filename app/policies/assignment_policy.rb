# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def index? = user.present?

  def new? = user.present?

  def create? = user.present? && (user&.admin_in?(record.roster) || not_assigning_someone_else?)

  def edit? = user.present?

  def update? = user.present? && (user&.admin_in?(record.roster) || not_assigning_someone_else?)

  def destroy? = user&.admin_in?(record.roster)

  private

  def not_assigning_someone_else?
    return true if user&.admin_in?(record.roster)
    return true unless record.user_changed?

    record.user == user
  end
end

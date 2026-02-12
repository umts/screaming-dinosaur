# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  authorize :roster, optional: true

  def manage? = allowed_to?(:manage?, record.roster)

  def index? = allowed_to?(:show?, roster)

  def create?
    return true if manage?

    member_of?(record.roster) && not_assigning_someone_else?
  end

  def update?
    return true if manage?

    member_of?(record.roster) && not_assigning_someone_else? && not_changing_dates?
  end

  private

  def not_assigning_someone_else? = record.changes.slice('user_id').blank? || record.user == user

  def not_changing_dates? = record.changes.slice('start_date', 'end_date').blank?
end

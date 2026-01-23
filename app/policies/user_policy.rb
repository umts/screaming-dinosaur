# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = user&.admin

  def update?
    return false unless manage? || record == user
    return false if record.changes.slice('spire', 'admin', 'active').present? && !manage?

    true
  end
end

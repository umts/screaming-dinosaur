# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = record == user

  def index? = user.present?

  def update?
    return false if record.changes.slice('spire', 'admin', 'active').present?

    manage?
  end
end

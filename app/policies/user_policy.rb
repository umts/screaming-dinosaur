# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = false

  def update? = user == record && record.changes.slice('admin', 'active').blank?
end

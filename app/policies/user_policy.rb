# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = false

  def update? = record == user && record.changes.slice('spire', 'admin', 'active').blank?
end

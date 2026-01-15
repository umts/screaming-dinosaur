# frozen_string_literal: true

class MaintenanceTaskPolicy < ApplicationPolicy
  def manage? = user&.admin
  alias_rule :index?, :new?, :create?, to: :manage?
end

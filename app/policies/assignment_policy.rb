# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  authorize :roster, optional: true

  def manage? = allowed_to?(:manage?, record.roster)

  def index? = allowed_to?(:show?, roster)
end

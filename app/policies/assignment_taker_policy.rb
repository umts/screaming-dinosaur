# frozen_string_literal: true

class AssignmentTakerPolicy < ApplicationPolicy
  def manage? = record.assignment.present? && allowed_to?(:show?, record.assignment.roster)
  def assign? = record.assignment.present? && allowed_to?(:manage?, record.assignment.roster)
end

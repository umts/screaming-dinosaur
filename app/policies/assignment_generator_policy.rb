# frozen_string_literal: true

class AssignmentGeneratorPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.roster)
end

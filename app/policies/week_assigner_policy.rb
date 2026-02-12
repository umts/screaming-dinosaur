# frozen_string_literal: true

class WeekAssignerPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.roster)
end

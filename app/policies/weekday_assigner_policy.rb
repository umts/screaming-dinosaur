# frozen_string_literal: true

class WeekdayAssignerPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.roster)
end

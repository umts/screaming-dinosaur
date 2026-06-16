# frozen_string_literal: true

class AssignmentTakerPolicy < ApplicationPolicy
  def manage? = user.present?
end

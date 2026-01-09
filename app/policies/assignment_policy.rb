# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  authorize :roster

  def index? = user&.member_of?(roster)
end

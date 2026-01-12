# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def index? = user.present?
end

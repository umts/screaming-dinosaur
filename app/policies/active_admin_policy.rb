# frozen_string_literal: true

class ActiveAdminPolicy < ApplicationPolicy
  def manage? = false
end

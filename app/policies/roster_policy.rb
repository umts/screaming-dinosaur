# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  def assignments? = user.present?
end

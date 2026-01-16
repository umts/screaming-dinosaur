# frozen_string_literal: true

class WeekdayAssignerPolicy < ApplicationPolicy
  authorize :roster

  def prompt? = user&.admin_in? roster

  def perform? = user&.admin_in? roster
end

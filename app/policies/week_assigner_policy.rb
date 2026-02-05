# frozen_string_literal: true

class WeekAssignerPolicy < ApplicationPolicy
  def prompt? = user&.admin_in? record.roster

  def perform? = user&.admin_in? record.roster
end

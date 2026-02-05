# frozen_string_literal: true

class WeekAssignerPolicy < ApplicationPolicy
  def manage? = admin_of?(record.roster)
end

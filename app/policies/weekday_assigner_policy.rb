# frozen_string_literal: true

class WeekdayAssignerPolicy < ApplicationPolicy
  def manage? = admin_of?(record.roster)
end

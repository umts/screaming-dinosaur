# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  authorize :roster, optional: true

  def manage? = admin_of?(record.try(:roster) || roster) || admin?

  def index? = member_of?(roster) || manage?
end

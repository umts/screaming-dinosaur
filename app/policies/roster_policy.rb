# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if admin?

    relation.joins(:memberships).where(memberships: { user: })
  end

  def manage? = admin_of?(record)

  def index? = logged_in?

  def show? = member_of?(record)
end

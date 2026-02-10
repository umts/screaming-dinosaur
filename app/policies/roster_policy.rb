# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if admin?

    relation.joins(:memberships).where(memberships: { user: })
  end

  def manage? = admin_of?(record)

  def index? = user.present?

  def show? = member_of?(record)

  private

  def member_of?(roster)
    roster.is_a?(Roster) && user&.memberships&.any? { |mem| mem.roster_id == roster.id }
  end

  def admin_of?(roster)
    roster.is_a?(Roster) && user&.memberships&.any? { |mem| mem.admin? && mem.roster_id == roster.id }
  end
end

# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if admin?

    relation.joins(:memberships).where(memberships: { user: })
  end

  def manage? = admin_of?(record) || admin?

  def index? = logged_in?

  def show? = member_of?(roster) || manage? || valid_api_key?
end

# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  authorize :roster, optional: true

  def index? = user&.member_of? roster

  def create? = user&.admin_in? record.roster

  def update? = user&.admin_in? record.roster

  def destroy? = user&.admin_in? record.roster
end

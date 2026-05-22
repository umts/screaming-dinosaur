# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  authorize :roster, optional: true

  def manage?
    allowed_to?(:manage?,
                record.roster) || (allowed_to?(:show?, record.roster) && record.user_id == user.id)
  end

  def index? = allowed_to?(:show?, roster)

  def new? = allowed_to?(:show?, record.roster)

  def edit? = allowed_to?(:show?, record.roster)
end

# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true
  authorize :api_key, optional: true

  pre_check :allow_admins

  alias_rule :index?, :create?, to: :manage?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?

  protected

  def logged_in? = user.present?

  def member_of?(roster)
    roster.is_a?(Roster) && user&.memberships&.any? { |mem| mem.roster_id == roster.id }
  end

  def admin_of?(roster)
    roster.is_a?(Roster) && user&.memberships&.any? { |mem| mem.admin? && mem.roster_id == roster.id }
  end

  private

  def allow_admins
    allow! if user&.admin
    allow! if api_key.present? && api_key == Rails.application.credentials.fetch(:api_key)
  end
end

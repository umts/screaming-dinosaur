# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true
  authorize :api_key, optional: true

  alias_rule :index?, :create?, to: :manage?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?

  protected

  def valid_api_key? = api_key.present? && api_key == Rails.application.credentials.fetch(:api_key)

  def member_of?(roster) = user.present? && user.member_of?(roster)

  def admin_of?(roster) = user.present? && user.admin_in?(roster)

  def admin? = user&.admin
end

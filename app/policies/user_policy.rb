# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = user&.admin
  alias_rule :index?, :new?, :create?, to: :manage?

  def edit? = manage? || (user == record)
  alias_rule :update?, to: :edit?
end

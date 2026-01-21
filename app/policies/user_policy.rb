# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index? = user&.admin?

  def new? = user&.admin?

  alias create? new?

  def edit? = user&.admin? || (user == record)

  alias update? edit?
end

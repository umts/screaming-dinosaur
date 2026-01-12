# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  def index? = user&.admin?

  def new? = user&.admin?
  alias create? new?

  def edit? = user&.admin_in?(record)
  alias update? edit?

  def assignments? = user.present?
end

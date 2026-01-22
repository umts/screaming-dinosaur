# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  authorize :roster

  def index? = user&.admin_in? roster

  def new? = user&.admin_in? roster
  alias create? new?

  def edit? = (user&.admin_in? roster) || (user == record)
  alias update? edit?

  def view_sensitive_info? = user&.admin_in?(roster)
end

# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  authorize :roster
  def index? = user.present?

  def new? = user&.admin_in? roster
  alias create? new?

  def edit? = (user&.admin_in? roster) || (user == record)
  alias update? edit?

  def transfer? = user&.admin_in? roster

  def destroy? = user&.admin_in? roster
end

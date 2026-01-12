# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  authorize :roster
  def index? = user.present?

  def new? = user&.admin_in? roster

  def create? = user&.admin_in? roster

  def edit? = (user&.admin_in? roster) || (user == record)

  def update? = (user&.admin_in? roster) || (user == record)

  def transfer? = user&.admin_in? roster

  def destroy? = user&.admin_in? roster
end

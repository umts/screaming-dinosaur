# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  def index? = user&.admin?

  def new? = user&.admin?

  def edit? = user&.admin_in?(record)

  def assignments? = user.present?
end

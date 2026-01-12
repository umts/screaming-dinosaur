# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  def index? = user&.admin?

  def new? = user&.admin?

  def assignments? = user.present?
end

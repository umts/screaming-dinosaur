# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def index? = user.present?

  def new? = user.present?

  def edit? = user.present?
end

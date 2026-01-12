# frozen_string_literal: true

class RosterPolicy < ApplicationPolicy
  def index? = user&.admin?

  def show? = user.present? || valid_api_key?

  def new? = user&.admin?
  alias create? new?

  def edit? = user&.admin_in?(record)
  alias update? edit?

  def destroy? = user&.admin_in?(record)

  def assignments? = user.present?

  def setup? = user&.admin_in?(record)
end

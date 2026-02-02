# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index? = logged_in?
end

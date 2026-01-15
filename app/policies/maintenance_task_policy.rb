# frozen_string_literal: true

class MaintenanceTaskPolicy < ApplicationPolicy
  def manage? = user&.admin
  alias index? manage?
  alias new? manage?
  alias create? manage?
end

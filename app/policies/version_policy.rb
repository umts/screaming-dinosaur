# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def manage? = logged_in? && user == record.author
end

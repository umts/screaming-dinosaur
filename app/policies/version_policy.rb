# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def undo? = logged_in? && user == record.author
end

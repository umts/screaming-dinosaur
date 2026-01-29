# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def undo? = user.present? && user == record.author
end

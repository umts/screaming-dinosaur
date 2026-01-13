# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def undo? = user&.id == record.whodunnit.to_i
end

# frozen_string_literal: true

class ChangePolicy < ApplicationPolicy
  authorize :user_id
  def undo? = user&.id == user_id
end

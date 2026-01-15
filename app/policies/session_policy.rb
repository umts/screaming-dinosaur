# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  if Rails.env.development?
    # :nocov:
    def create? = true
    # :nocov:
  end

  def destroy? = true
end

# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  if Rails.env.development?
    def create? = true
  end

  def destroy? = true
end

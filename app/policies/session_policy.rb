# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  if Rails.env.local?
    def create? = true
  end

  def destroy? = true
end

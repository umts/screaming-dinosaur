# frozen_string_literal: true

class TwilioPolicy < ApplicationPolicy
  def call? = true

  def text? = true
end

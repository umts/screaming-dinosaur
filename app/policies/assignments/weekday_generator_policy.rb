# frozen_string_literal: true

module Assignments
  class WeekdayGeneratorPolicy < ApplicationPolicy
    authorize :roster

    def prompt? = user&.admin_in? roster

    def perform? = user&.admin_in? roster
  end
end

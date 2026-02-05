# frozen_string_literal: true

class FeedPolicy < ApplicationPolicy
  def show? = allowed_to?(:index?, Assignment, context: { roster: record.roster })
end

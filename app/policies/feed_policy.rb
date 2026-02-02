# frozen_string_literal: true

class FeedPolicy < ApplicationPolicy
  def show? = member_of?(record.roster)
end

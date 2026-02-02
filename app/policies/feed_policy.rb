# frozen_string_literal: true

class FeedPolicy < ApplicationPolicy
  def show?
    user&.member_of?(record.roster)
  end
end

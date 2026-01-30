# frozen_string_literal: true

class FeedPolicy < ApplicationPolicy
  def show?
    return true if user&.present? && user&.member?(roster) || user&.admin_in?(roster)
    return true if params[:token] == roster.allow_calendar_token_access
  end
end

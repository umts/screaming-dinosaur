# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def manage? = user.present? && user == record.author
end

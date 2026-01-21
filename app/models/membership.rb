# frozen_string_literal: true

class Membership < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :roster
  validates :user, uniqueness: { scope: :roster }
  validate :at_least_one_admin
  after_destroy :delete_future_assignment

  private

  def at_least_one_admin
    return unless admin_changed?(to: false) && roster.admins.one?

    errors.add :user, 'is the last admin and cannot be demoted'
  end

  def delete_future_assignment
    user.assignments
        .where(roster: roster)
        .upcoming
        .destroy_all
  end
end

# frozen_string_literal: true

class Membership < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :roster

  validates :user_id, uniqueness: { scope: :roster_id }

  after_destroy :delete_future_assignments

  private

  def delete_future_assignments
    user.assignments.where(roster:).future.each(&:destroy!)
  end
end

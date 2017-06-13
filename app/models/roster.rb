# frozen_string_literal: true

class Roster < ApplicationRecord
  has_paper_trail
  has_many :assignments, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships
  belongs_to :fallback_user, class_name: 'User', foreign_key: :fallback_user_id

  validates :name, presence: true, uniqueness: true

  def generate_assignments(user_ids, start_date, end_date, start_user_id)
    assignments = []
    user_ids.rotate! user_ids.index(start_user_id)
    (start_date..end_date).each_slice(7).with_index do |week, i|
      assignments << Assignment.create!(
        roster: self,
        start_date: week.first,
        end_date: week.last,
        user_id: user_ids[i % user_ids.size]
      )
    end
    assignments
  end

  def on_call_user
    assignments.current.try(:user) || fallback_user
  end
end

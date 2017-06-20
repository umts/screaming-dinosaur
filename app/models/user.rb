# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail
  has_many :assignments, dependent: :restrict_with_error
  has_many :memberships
  has_many :rosters, through: :memberships

  validates :first_name, :last_name, :spire, :email, :phone, :rosters,
            presence: true
  validates :spire, :email, :phone,
            uniqueness: true
  validates :spire,
            format: { with: /\A\d{8}@umass.edu\z/,
                      message: 'must be 8 digits followed by @umass.edu' }
  validates :phone,
            format: { with: /\A\+1\d{10}\z/,
                      message: 'must be "+1" followed by 10 digits' }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def admin_in?(roster)
    membership_in(roster).try(:admin?) || false
  end

  def admin?
    memberships.any?(&:admin?)
  end

  def membership_in(roster)
    memberships.find_by(roster: roster)
  end
end

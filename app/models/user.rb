# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail
  has_secure_token :calendar_access_token

  has_many :assignments, dependent: :restrict_with_error
  has_many :memberships, dependent: :destroy
  has_many :rosters, through: :memberships
  has_many :fallback_rosters, class_name: 'Roster',
                              foreign_key: :fallback_user_id,
                              inverse_of: 'fallback_user',
                              dependent: :nullify
  has_many :authored_versions, dependent: :restrict_with_error,
                               class_name: 'Version',
                               foreign_key: :whodunnit,
                               inverse_of: :author

  validates :first_name, :last_name, :spire, :email, :phone, :rosters, presence: true
  validates :spire, :email, :phone, uniqueness: { case_sensitive: false }
  validates :calendar_access_token, uniqueness: { case_sensitive: true }
  validates :spire, format: { with: /\A\d{8}@umass.edu\z/, message: :spire_must_be_8_digits_with_umass }
  validates :phone, phone: true

  before_save :regenerate_calendar_access_token, if: -> { calendar_access_token.blank? }
  before_save -> { assignments.future.destroy_all }, if: :being_deactivated?

  scope :active, -> { where active: true }
  scope :inactive, -> { where active: false }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def member_of?(roster) = rosters.include?(roster)

  def admin_in?(roster)
    membership_in(roster).try(:admin?) || false
  end

  def admin?
    memberships.any?(&:admin?)
  end

  def membership_in(roster)
    memberships.find_by(roster:)
  end

  private

  def being_deactivated?
    active_changed? && !active?
  end
end

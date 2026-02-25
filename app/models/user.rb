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

  validates :first_name, :last_name, :spire, :email, :phone, presence: true
  validates :spire, :email, :phone, uniqueness: { case_sensitive: false }
  validates :calendar_access_token, uniqueness: { case_sensitive: true }
  validates :spire, format: { with: /\A\d{8}@umass.edu\z/, message: :must_be_fc_id_number }
  validates :phone, phone: true
  validate :prevent_self_deactivation, if: :being_deactivated?

  before_save :regenerate_calendar_access_token, if: -> { calendar_access_token.blank? }
  before_save -> { assignments.future.destroy_all }, if: :being_deactivated?
  after_commit :notify_fallback_rosters_of_phone_change, on: :update

  scope :active, -> { where active: true }
  scope :inactive, -> { where active: false }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  private

  def being_deactivated?
    active_changed? && !active?
  end

  def prevent_self_deactivation
    return unless Current.user == self

    errors.add :base, message: :may_not_deactivate_self
  end

  def notify_fallback_rosters_of_phone_change
    return unless phone_previously_changed?

    fallback_rosters.includes(:admins).find_each do |roster|
      next if roster.admins.empty?

      RosterMailer.with(roster: roster).fallback_number_changed.deliver_later
    end
  end
end

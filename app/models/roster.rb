# frozen_string_literal: true

require 'csv'

class Roster < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: :slugged

  has_paper_trail

  belongs_to :fallback_user, class_name: 'User', optional: true, inverse_of: 'fallback_rosters'
  has_many :assignments, dependent: :destroy
  has_many :memberships, dependent: :destroy

  has_one :current_assignment,
          -> { ending_after(Time.current).order(end_datetime: :asc).order(end_datetime: :asc) },
          class_name: 'Assignment', dependent: nil, inverse_of: :roster
  has_many :admin_memberships, -> { where(admin: true) }, class_name: 'Membership', dependent: nil, inverse_of: :roster

  has_many :users, through: :memberships
  has_many :admins, through: :admin_memberships, source: :user

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :switchover, numericality: { in: (0...(24 * 60)), message: :invalid_time }
  validates :phone, presence: true, phone: { allow_blank: true }

  after_commit :notify_fallback_number_changed, on: :update

  def on_call_user = current_assignment&.user || fallback_user

  def switchover_time
    switchover.presence && Time.zone.now.midnight.in(switchover.minutes)
  end

  def switchover_time=(value)
    value.tap do |castable|
      castable = castable.to_time if castable.respond_to?(:to_time)
      castable = (castable.hour * 60) + castable.min if castable.is_a?(Time)
      self.switchover = castable
    end
  end

  def uncovered_datetimes_between(start_datetime, end_datetime)
    (start_datetime..end_datetime).step(1.day).to_a -
      assignments.ending_after(start_datetime).ending_before(end_datetime).inject([]) do |datetimes, assignment|
        datetimes | (assignment.start_datetime..assignment.end_datetime).step(1.day).to_a
      end
  end

  # Returns the day AFTER the last assignment ends.
  # If there is no last assignment, returns the upcoming Friday.
  def next_rotation_start_date
    last = assignments.order(:end_datetime).last
    if last.present?
      last.end_datetime + 1.day
    else
      Time.current.next_occurring :friday
    end
  end

  private

  def notify_fallback_number_changed
    return unless fallback_user_id_previously_changed?
    return if admins.empty?

    RosterMailer.with(roster: self).fallback_number_changed.deliver_later
  end
end

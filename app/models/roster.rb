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
  validates :phone, presence: true, phone: { allow_blank: true }

  after_commit :notify_fallback_number_changed, on: :update

  def on_call_user = current_assignment&.user || fallback_user

  def uncovered_periods_between(start_time, end_time)
    last = assignments.order(end_datetime: :desc).first
    return [{ start_datetime: start_time, end_datetime: end_time }] if last.nil?

    gaps = unassigned_periods_between(start_time, end_time)
    if last.end_datetime < end_time
      gaps << { start_datetime: [last.end_datetime, start_time].max, end_datetime: end_time }
    end
    gaps
  end

  private

  def unassigned_periods_between(start_time, end_time)
    start_datetime = Assignment.arel_table[:start_datetime]
    Assignment.with_start_datetimes.where(roster_id: id, user_id: nil)
              .where(start_datetime.lt(end_time))
              .where(Assignment.arel_table[:end_datetime].gt(start_time))
              .map do |a|
                {
                  start_datetime: [a.start_datetime, start_time].max,
                  end_datetime: [a.end_datetime, end_time].min
                }
              end
  end

  def notify_fallback_number_changed
    return unless fallback_user_id_previously_changed?
    return if admins.empty?

    RosterMailer.with(roster: self).fallback_number_changed.deliver_later
  end
end

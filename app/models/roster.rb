# frozen_string_literal: true

require 'csv'

class Roster < ApplicationRecord
  include PhoneHelper

  has_paper_trail
  has_many :assignments, dependent: :destroy

  has_many :memberships, dependent: :destroy
  has_many :admin_memberships, -> { where(admin: true) },
           class_name: 'Membership', inverse_of: :roster
  has_many :non_admin_memberships, -> { where.not(admin: true) },
           class_name: 'Membership', inverse_of: :roster

  has_many :users, through: :memberships
  has_many :admins, through: :admin_memberships, source: :user
  has_many :non_admins, through: :non_admin_memberships, source: :user

  belongs_to :fallback_user, class_name: 'User',
                             optional: true,
                             inverse_of: 'fallback_rosters'

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :switchover, numericality: { in: (0...(24 * 60)) }

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

  def switchover_time
    switchover.presence && Time.zone.now.midnight.in(switchover.minutes)
  end

  def user_options
    as = admins.order(:last_name).map { |a| [a.full_name, a.id] }
    nas = non_admins.order(:last_name).map { |na| [na.full_name, na.id] }
    { 'Admins' => as, 'Non-Admins' => nas }
  end

  def uncovered_dates_between(start_date, end_date)
    (start_date.to_date..end_date.to_date).to_a -
      assignments.between(start_date.to_date, end_date.to_date).inject([]) do |dates, assignment|
        dates | (assignment.start_date..assignment.end_date).to_a
      end
  end

  def assignment_csv
    CSV.generate headers: %w[roster email first_name last_name start_date end_date created_at updated_at],
                 write_headers: true do |csv|
      assignments.sort_by(&:start_date).each do |assignment|
        csv << assignment_csv_row(assignment)
      end
    end
  end

  private

  def assignment_csv_row(assignment)
    { 'roster' => name,
      'email' => assignment.user.email,
      'first_name' => assignment.user.first_name,
      'last_name' => assignment.user.last_name,
      'start_date' => assignment.start_date.to_fs(:db),
      'end_date' => assignment.end_date.to_fs(:db),
      'created_at' => assignment.created_at.to_fs(:db),
      'updated_at' => assignment.updated_at.to_fs(:db) }
  end
end

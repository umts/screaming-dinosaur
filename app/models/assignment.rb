class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :rotation

  validates :user, :start_date, :end_date, :rotation,
            presence: true
  validate :overlaps_any?

  class << self
    # The current assignment - this method accounts for the 5pm switchover hour.
    def current
      if Time.zone.now.hour < CONFIG.fetch(:switchover_hour)
        on Date.yesterday
      else on Date.today
      end
    end

    # Generates a weekly rotation over a date range
    # switching on the weekday of the start date
    # starting with the user whose ID is in start_user_id
    def generate_rotation(user_ids, start_date, end_date, start_user_id)
      assignments = []
      user_ids.rotate! user_ids.index(start_user_id)
      (start_date..end_date).each_slice(7).with_index do |week, i|
        assignments << create(
          start_date: week.first,
          end_date: week.last,
          user_id: user_ids[i % user_ids.size]
        )
      end
      assignments
    end

    # Returns the day AFTER the last assignment ends.
    # If there is no last assignment, returns nil.
    def next_rotation_start_date
      last = order(:end_date).last
      last.end_date + 1.day if last.present?
    end

    # returns the assignment which takes place on a particular date
    def on(date)
      find_by("
        start_date <= ? AND end_date >=?
      ", date, date)
    end

    # If it's before 5pm, return assignments that start today or after.
    # It it's after 5pm, return assignments that start tomorrow or after.
    def upcoming
      if Time.zone.now.hour < CONFIG.fetch(:switchover_hour)
        where 'start_date >= ?', Date.today
      else where 'start_date > ?', Date.today
      end
    end
  end

  private

  def overlaps_any?
    overlapping_assignments = Assignment.where("
      start_date <= ? AND end_date >= ? AND id != ?
    ", end_date, start_date, id)
    return if overlapping_assignments.blank?
    errors.add :base,
               'Overlaps with another assignment'
  end
end

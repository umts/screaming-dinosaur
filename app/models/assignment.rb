class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :rotation

  validates :user, :start_date, :end_date, :rotation,
            presence: true
  validate :overlaps_any?
  validate :user_in_rotation?

  class << self
    # The current assignment - this method accounts for the 5pm switchover hour.
    # This should be called while scoped to a particular rotation.
    def current
      if Time.zone.now.hour < CONFIG.fetch(:switchover_hour)
        on Date.yesterday
      else on Date.today
      end
    end

    def in(rotation)
      where rotation: rotation
    end

    # Returns the day AFTER the last assignment ends.
    # If there is no last assignment, returns the upcoming Friday.
    def next_rotation_start_date
      last = order(:end_date).last
      if last.present?
        last.end_date + 1.day
      else 1.week.since.beginning_of_week(:friday).to_date
      end
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
    if new_record?
      overlapping_assignments = rotation.assignments.where("
        start_date < ? AND end_date >= ?
      ", end_date, start_date)
    else
      overlapping_assignments = rotation.assignments.where("
        start_date < ? AND end_date >= ? AND id != ?
      ", end_date, start_date, id)
    end
    return if overlapping_assignments.blank?
    errors.add :base,
               'Overlaps with another assignment'
  end

  def user_in_rotation?
    unless rotation.users.include? user
      errors.add :base, 'User is not in this rotation'
    end
  end
end

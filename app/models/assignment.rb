class Assignment < ActiveRecord::Base
  belongs_to :user

  validates :user, :start_date, :end_date,
            presence: true
  validate :overlaps_any?

  scope :upcoming, -> { where 'start_date > ?', Date.today }

  # The current assignment - this method accounts for the 5pm switchover hour.
  def self.current
    if Time.zone.now.hour < CONFIG.fetch(:switchover_hour)
      on Date.yesterday
    else on Date.today
    end
  end

  # Generates a weekly rotation over a date range
  # switching on the weekday of the start date
  # user_ids should be an array of Fixnums
  def self.generate_rotation(user_ids, start_date, end_date)
    assignments = []
    (start_date..end_date).each_slice(7).with_index do |week, i|
      assignments << create(
        start_date: week.first,
        end_date: week.last,
        user_id: user_ids[i % user_ids.size]
      )
    end
    assignments
  end

  # returns the assignment which takes place on a particular date
  def self.on(date)
    find_by("
      start_date <= ? AND end_date >=?
    ", date, date)
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

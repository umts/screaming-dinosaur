class Assignment < ActiveRecord::Base
  belongs_to :user

  validates :user, :start_date, :end_date,
            presence: true
  validate :overlaps_any?

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

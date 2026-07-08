# frozen_string_literal: true

class AssignmentGenerator
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :roster_id, :integer
  attribute :user_id, :integer
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :end_time, :time
  attribute :weekdays, default: -> { [] }
  attribute :group, :string

  validates :roster, presence: true
  validates :user, presence: true
  validates :weekdays, presence: true
  validates :end_time, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true,
                       comparison: { greater_than_or_equal_to: :start_date,
                                     if: -> { start_date.present? && end_date.present? },
                                     message: :must_not_be_before_start }

  def perform
    perform!
    true
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
    false
  end

  def roster
    return @roster if defined?(@roster)

    @roster = Roster.find_by(id: roster_id)
  end

  private

  def perform!
    validate!
    ActiveRecord::Base.transaction do
      generate_assignments_with_group
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.merge! e.record.errors
    raise e
  end

  def user
    return @user if defined?(@user)

    @user = User.find_by(id: user_id)
  end

  def date_range
    (start_date..end_date).to_a
  end

  def selected_weekdays?(date)
    weekdays.include?(date.strftime('%A'))
  end

  def combine(date, time)
    Time.zone.local(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.min
    )
  end

  def generate_assignments
    date_range.each do |date|
      next unless selected_weekdays?(date)

      roster.assignments.create! user:, end_datetime: combine(date, end_time)
    end
  end

  def each_week
    week_start = start_date
    while week_start <= end_date
      week_end = [week_start.end_of_week(:monday), end_date].min
      yield week_start, week_end
      week_start = week_end + 1.day
    end
  end

  def generate_assignments_with_group
    return generate_assignments if group.blank?

    each_week do |week_start, week_end|
      assignment_group = AssignmentGroup.create!(name: group)

      (week_start..week_end).each do |date|
        next unless selected_weekdays?(date)

        roster.assignments.create!(
          user: user,
          end_datetime: combine(date, end_time),
          assignment_group: assignment_group
        )
      end
    end
  end
end

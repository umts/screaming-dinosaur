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

  def perform!
    validate!
    ActiveRecord::Base.transaction do
      date_range.each do |date|
        next unless selected_weekdays?(date)

        roster.assignments.create! user:, end_datetime: combine(date, end_time)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.merge! e.record.errors
    raise e
  end

  private

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
end

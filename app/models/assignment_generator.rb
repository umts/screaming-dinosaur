# frozen_string_literal: true

class AssignmentGenerator
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :roster_id, :integer
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :auto_assign, :boolean

  validates :roster, presence: true
  validates :definitions, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true,
                       comparison: { greater_than_or_equal_to: :start_date,
                                     if: -> { start_date.present? && end_date.present? },
                                     message: :must_not_be_before_start }
  validate :definitions_are_valid

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

  def definitions
    @definitions ||= [AssignmentGeneratorDefinition.new]
  end

  def definitions_attributes=(attrs)
    collection = attrs.sort_by { |key, _| key.to_i }.map { |_, value| value }
    @definitions = collection.map { |attributes| AssignmentGeneratorDefinition.new(attributes) }
  end

  def peek_next_user
    user_iterator.peek
  end

  private

  def definitions_are_valid
    definitions.each do |definition|
      errors.merge!(definition.errors) unless definition.valid?
    end
  end

  def perform!
    validate!
    ActiveRecord::Base.transaction do
      definitions.each do |definition|
        generate_assignments_with_group(definition)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.merge! e.record.errors
    raise e
  end

  def selected_weekdays?(definition, date)
    definition.weekdays.include?(date.strftime('%A'))
  end

  def end_datetime_for_assignment(date, definition)
    date += 1.day if definition.overnight?
    Time.zone.local(
      date.year,
      date.month,
      date.day,
      definition.end_time.hour,
      definition.end_time.min
    )
  end

  def each_week
    week_start = start_date
    while week_start <= end_date
      week_end = [week_start.end_of_week(:monday), end_date].min
      yield week_start, week_end
      week_start = week_end + 1.day
    end
  end

  def user_iterator
    unless @user_iterator
      @user_iterator = roster.users.order(:last_name).cycle
      if roster.assignments.present?
        @user_iterator.next while @user_iterator.peek != roster.assignments.order(:end_datetime).last.user
        @user_iterator.next # The previous loop will halt on the last assigned user, we want the user after that!
      end
    end

    @user_iterator
  end

  def next_user_for_assignment
    return nil unless auto_assign && roster.users.present?

    user_iterator.next
  end

  def generate_assignments_with_group(definition)
    each_week do |week_start, week_end|
      assignment_group = AssignmentGroup.create!(name: definition.group) if definition.group.present?

      (week_start..week_end).select { |date| selected_weekdays?(definition, date) }.each do |date|
        roster.assignments.create!(
          end_datetime: end_datetime_for_assignment(date, definition),
          assignment_group:,
          credits: definition.credits,
          user: next_user_for_assignment
        )
      end
    end
  end
end

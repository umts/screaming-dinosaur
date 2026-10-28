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
  validate :roster_has_users?, if: -> { auto_assign }

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

  private

  def definitions_are_valid
    definitions.each do |definition|
      errors.merge!(definition.errors) unless definition.valid?
    end
  end

  def roster_has_users?
    roster.users.present?
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

  def generate_assignments_with_group(definition)
    each_week do |week_start, week_end|
      assignment_group = AssignmentGroup.create!(name: definition.group) if definition.group.present?

      (week_start..week_end).each do |date|
        next unless selected_weekdays?(definition, date)

        end_datetime = end_datetime_for_assignment(date, definition)
        roster.assignments.create!(
          end_datetime:,
          assignment_group:,
          credits: definition.credits
        )
      end
    end
  end
end

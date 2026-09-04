# frozen_string_literal: true

class AssignmentGenerator
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :roster_id, :integer
  attribute :user_id, :integer

  validates :roster, presence: true
  validates :user, presence: true
  validates :definitions, presence: true
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
    @definitions ||= []
  end

  def definitions_attributes=(attrs)
    collection = attrs.is_a?(Array) ? attrs : attrs.sort_by { |key, _| key.to_i }.map { |_, value| value }
    @definitions = collection.map { |attributes| AssignmentGeneratorDefinition.new(attributes) }
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

  def user
    return @user if defined?(@user)

    @user = User.find_by(id: user_id)
  end

  def date_range(definition)
    (definition.start_date..definition.end_date).to_a
  end

  def selected_weekdays?(definition, date)
    definition.weekdays.include?(date.strftime('%A'))
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

  def generate_assignments(definition)
    date_range(definition).each do |date|
      next unless selected_weekdays?(definition, date)

      roster.assignments.create! user:, end_datetime: combine(date, definition.end_time)
    end
  end

  def each_week(definition)
    week_start = definition.start_date
    while week_start <= definition.end_date
      week_end = [week_start.end_of_week(:monday), definition.end_date].min
      yield week_start, week_end
      week_start = week_end + 1.day
    end
  end

  def generate_assignments_with_group(definition)
    return generate_assignments(definition) if definition.group.blank?

    each_week(definition) do |week_start, week_end|
      assignment_group = AssignmentGroup.create!(name: definition.group)

      (week_start..week_end).each do |date|
        next unless selected_weekdays?(definition, date)

        roster.assignments.create!(
          user: user,
          end_datetime: combine(date, definition.end_time),
          assignment_group: assignment_group
        )
      end
    end
  end
end

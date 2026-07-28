# frozen_string_literal: true

class AssignmentGeneratorDefinition
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :start_date, :date
  attribute :end_date, :date
  attribute :end_time, :time
  attribute :weekdays, default: -> { [] }
  attribute :group, :string

  validates :weekdays, presence: true
  validates :end_time, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true,
                       comparison: { greater_than_or_equal_to: :start_date,
                                     if: -> { start_date.present? && end_date.present? },
                                     message: :must_not_be_before_start }
end

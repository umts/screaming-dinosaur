# frozen_string_literal: true

class AssignmentGeneratorDefinition
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :end_time, :time
  attribute :weekdays, default: -> { [] }
  attribute :group, :string
  attribute :overnight, :boolean
  attribute :credits, :integer, default: 1

  validates :weekdays, presence: true
  validates :end_time, presence: true
  validates :credits, presence: true, comparison: { greater_than_or_equal_to: 0 }

  alias :overnight? overnight
end

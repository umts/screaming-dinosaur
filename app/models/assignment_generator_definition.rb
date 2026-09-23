# frozen_string_literal: true

class AssignmentGeneratorDefinition
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :end_time, :time
  attribute :weekdays, default: -> { [] }
  attribute :group, :string
  attribute :overnight, :boolean

  validates :weekdays, presence: true
  validates :end_time, presence: true

  alias :overnight? overnight
end

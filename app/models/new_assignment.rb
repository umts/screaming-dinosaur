# frozen_string_literal: true

class NewAssignment < ApplicationRecord
  has_paper_trail

  attribute :start_datetime, :datetime

  belongs_to :user, optional: true
  belongs_to :roster

  validates :end_datetime, presence: true, uniqueness: { scope: :roster_id }

  scope :with_start_datetimes, lambda {
    start_datetime = Arel::Nodes::Over.new(
      Arel::Nodes::NamedFunction.new('LAG', [arel_table[:end_datetime]]),
      Arel::Nodes::Window.new
                         .partition(arel_table[:roster_id])
                         .order(arel_table[:end_datetime])
    ).as(arel_table[:start_datetime].name)
    from arel_table.project(arel_table[Arel.star], start_datetime).as(arel_table.name)
  }
end

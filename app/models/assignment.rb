# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail

  attribute :start_datetime, :datetime

  belongs_to :roster
  belongs_to :user, optional: true

  validates :end_datetime, presence: true, uniqueness: { scope: :roster_id }

  def start_datetime = super.presence || previous&.end_datetime || roster.created_at

  def previous
    roster.assignments
          .where(self.class.arel_table[:end_datetime].lt(end_datetime))
          .order(end_datetime: :desc).first
  end

  def next
    roster.assignments
          .where(self.class.arel_table[:end_datetime].gt(end_datetime))
          .order(end_datetime: :asc).first
  end

  class << self
    def with_start_datetimes
      from arel_table.project(arel_table[Arel.star], start_datetime_node).as(arel_table.name)
    end

    private

    def start_datetime_node
      Arel::Nodes::Over.new(
        Arel::Nodes::NamedFunction.new('LAG', [arel_table[:end_datetime]]),
        Arel::Nodes::Window.new.partition(arel_table[:roster_id]).order(arel_table[:end_datetime])
      ).as(arel_table[:start_datetime].name)
    end
  end
end

# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail

  attribute :start_datetime, :datetime

  belongs_to :roster
  belongs_to :user, optional: true

  validates :end_datetime, presence: true, uniqueness: { scope: :roster_id }

  scope :ending_before, ->(time) { where(arel_table[:end_datetime].lt(time)) }
  scope :ending_after, ->(time) { where(arel_table[:end_datetime].gt(time)) }
  scope :overlapping, ->(range) { where(start_datetime: nil..range.end, end_datetime: range.begin..nil) }

  def start_datetime = super.presence || previous&.end_datetime || roster.created_at

  def previous = roster.assignments.ending_before(end_datetime).order(end_datetime: :desc).first

  def next = roster.assignments.ending_after(end_datetime).order(end_datetime: :asc).first

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

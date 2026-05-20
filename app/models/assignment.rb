# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail

  attribute :start_datetime, :datetime

  belongs_to :roster
  belongs_to :user, optional: true

  validates :end_datetime, comparison: { greater_than: ->(assignment) { assignment.roster.created_at },
                                         if: ->(assignment) { assignment.roster.present? },
                                         allow_nil: true },
                           presence: true,
                           uniqueness: { scope: :roster_id }

  scope :ending_before, ->(time) { where(arel_table[:end_datetime].lt(time)) }
  scope :ending_after, ->(time) { where(arel_table[:end_datetime].gt(time)) }

  def start_datetime = super.presence || previous&.end_datetime || roster.created_at

  def previous = roster.assignments.ending_before(end_datetime).order(end_datetime: :desc).first

  def next = roster.assignments.ending_after(end_datetime).order(end_datetime: :asc).first

  class << self
    def with_start_datetimes
      from arel_table.join(Roster.arel_table).on(arel_table[:roster_id].eq(Roster.arel_table[:id]))
                     .project(arel_table[Arel.star], start_datetime_node)
                     .as(arel_table.name)
    end

    def send_reminders!
      assignments_in_next_week.group_by(&:user).each do |user, assignments|
        AssignmentsMailer.upcoming_reminder(user, assignments).deliver_now
      end
    end

    def to_csv # rubocop:disable Metrics
      CSV.generate headers: %i[roster email first_name last_name start end created_at updated_at],
                   write_headers: true do |csv|
        all.each do |assignment| # rubocop:disable Rails/FindEach
          csv << {
            roster: assignment.roster.name,
            email: assignment.user&.email,
            first_name: assignment.user&.first_name,
            last_name: assignment.user&.last_name,
            start: assignment.start_datetime.iso8601,
            end: assignment.end_datetime.iso8601,
            created_at: assignment.created_at.iso8601,
            updated_at: assignment.updated_at.iso8601
          }
        end
      end
    end

    private

    def assignments_in_next_week # rubocop:disable Metrics/AbcSize
      start_time = (Date.current.beginning_of_week(:monday) + 1.week).in_time_zone.beginning_of_day
      end_time = start_time + 1.week
      start_datetime = arel_table[:start_datetime]
      with_start_datetimes.where(start_datetime.gteq(start_time))
                          .where(start_datetime.lt(end_time))
                          .where.not(user_id: nil)
                          .includes(:roster, :user)
    end

    def start_datetime_node
      Arel::Nodes::Over.new(
        Arel::Nodes::NamedFunction.new('LAG', [arel_table[:end_datetime],
                                               Arel::Nodes::SqlLiteral.new('1'),
                                               Roster.arel_table[:created_at]]),
        Arel::Nodes::Window.new.partition(arel_table[:roster_id]).order(arel_table[:end_datetime])
      ).as(arel_table[:start_datetime].name)
    end
  end
end

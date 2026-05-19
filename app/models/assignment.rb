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

  after_commit :notify_user_of_assignment
  after_commit :notify_user_of_change
  after_commit :notify_user_of_removal

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

    def to_csv # rubocop:disable Metrics
      CSV.generate headers: %i[roster email first_name last_name start end created_at updated_at],
                   write_headers: true do |csv|
        all.each do |assignment| # rubocop:disable Rails/FindEach
          csv << {
            roster: assignment.roster.name,
            email: assignment.user.email,
            first_name: assignment.user.first_name,
            last_name: assignment.user.last_name,
            start: assignment.start_datetime.iso8601,
            end: assignment.end_datetime.iso8601,
            created_at: assignment.created_at.iso8601,
            updated_at: assignment.updated_at.iso8601
          }
        end
      end
    end

    private

    def start_datetime_node
      Arel::Nodes::Over.new(
        Arel::Nodes::NamedFunction.new('LAG', [arel_table[:end_datetime],
                                               Arel::Nodes::SqlLiteral.new('1'),
                                               Roster.arel_table[:created_at]]),
        Arel::Nodes::Window.new.partition(arel_table[:roster_id]).order(arel_table[:end_datetime])
      ).as(arel_table[:start_datetime].name)
    end

    def notify_user_of_assignment
      return unless user_id_previously_changed?
      return if user.blank?
      return if user == Current.user
      return unless user.change_notifications_enabled?

      AssignmentsMailer.new_assignment(roster, start_datetime, end_datetime, user, Current.user)
                       .deliver_later
    end

    def notify_user_of_change
      return if previously_new_record?
      return if user_id_previously_changed?
      return unless end_datetime_previously_changed?
      return if user.blank?
      return if user == Current.user
      return unless user.change_notifications_enabled?

      AssignmentsMailer.changed_assignment(roster, start_datetime, end_datetime, user, Current.user)
                       .deliver_later
    end

    def notify_user_of_removal
      return unless previously_persisted? || user_id_previously_changed?

      previous_user = previously_persisted? ? user : User.find_by(id: user_id_previously_was)
      return if previous_user.blank?
      return if previous_user == Current.user
      return unless previous_user.change_notifications_enabled?

      AssignmentsMailer.deleted_assignment(roster,
                                           start_datetime, end_datetime,
                                           previous_user, Current.user)
                       .deliver_later
    end
  end
end

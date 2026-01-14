# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :roster

  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
  validate :overlaps_none
  validate :user_in_roster

  scope :future, -> { where 'start_date > ?', Time.zone.today }
  scope :at, ->(time) { joins(:roster).where(start_time_node.lteq(time)).where(end_time_node.gt(time)) }

  def effective_start_datetime
    start_date + roster.switchover.minutes
  end

  # Assignments effectively end at the switchover hour on the following day.
  def effective_end_datetime
    end_date + 1.day + roster.switchover.minutes
  end

  def notify(receiver, of:, by:)
    receiver = user if receiver == :owner
    mailer_method = of
    changer = by
    return unless receiver != changer && receiver.change_notifications_enabled?

    mail = AssignmentsMailer.send mailer_method, self, receiver, changer
    mail.deliver_now
  end

  class << self
    def between(start_date, end_date)
      where arel_table[:start_date].lteq(end_date).and(arel_table[:end_date].gteq(start_date))
    end

    # The current assignment - this method accounts for the switchover hour.
    # This should be called while scoped to a particular roster.
    def current
      joins(:roster).on(effective_date)
    end

    def effective_date
      switchover = Roster.arel_table[:switchover]
      yesterday = Arel::Nodes.build_quoted(Date.yesterday)
      today = Arel::Nodes.build_quoted(Time.zone.today)

      # If it's after the roster's switchover, use "Today", otherwise it's still "Yesterday".
      # e.g. IF(1020 >= `roster`.`switchover`, '2023-09-01', '2023-08-31')
      Arel::Nodes::NamedFunction.new('IF', [minutes_since_midnight.gteq(switchover), today, yesterday])
    end

    def start_time_node = time_node(:start_date)

    def end_time_node
      Arel::Nodes::NamedFunction.new 'TIMESTAMPADD',
                                     [Arel::Nodes::SqlLiteral.new('DAY'),
                                      Arel::Nodes::SqlLiteral.new('1'),
                                      time_node(:end_date)]
    end

    def in(roster)
      where roster:
    end

    # returns the assignment which takes place on a particular date
    def on(date)
      between(date, date).first
    end

    def upcoming
      joins(:roster).where arel_table[:start_date].gt(effective_date)
    end

    def send_reminders!
      where(start_date: Date.tomorrow).find_each do |assignment|
        AssignmentsMailer.upcoming_reminder(assignment).deliver_now
      end
    end

    private

    def time_node(column)
      Arel::Nodes::NamedFunction.new 'TIMESTAMPADD',
                                     [Arel::Nodes::SqlLiteral.new('MINUTE'),
                                      Roster.arel_table[:switchover],
                                      arel_table[column]]
    end
  end

  private

  def overlaps_none
    # A non-new record always overlaps itself, so we exclude it from our query.
    return if roster.assignments
                    .where('`start_date` <= ? AND `end_date` >= ?', end_date, start_date)
                    .excluding(self)
                    .none?

    errors.add :base, 'Overlaps with another assignment'
  end

  def user_in_roster
    return if roster.users.include? user

    errors.add :base, 'User is not in this roster'
  end
end

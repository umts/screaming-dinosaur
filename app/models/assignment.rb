# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :roster

  validates :start_date, presence: true
  validates :end_date, presence: true,
                       comparison: { greater_than_or_equal_to: :start_date,
                                     if: -> { start_date.present? && end_date.present? },
                                     message: :must_not_be_before_start }
  validate :overlaps_none
  validate :user_in_roster

  after_commit :notify_user_of_assignment
  after_commit :notify_user_of_change
  after_commit :notify_user_of_removal

  scope :future, -> { where 'start_date > ?', Time.zone.today }

  def effective_start_datetime
    start_date + roster.switchover.minutes
  end

  # Assignments effectively end at the switchover hour on the following day.
  def effective_end_datetime
    end_date + 1.day + roster.switchover.minutes
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
        AssignmentsMailer.upcoming_reminder(assignment.roster, assignment.effective_start_datetime,
                                            assignment.effective_end_datetime, assignment.user).deliver_now
      end
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

  def notify_user_of_assignment
    return unless user_id_previously_changed?
    return if user == Current.user
    return unless user.change_notifications_enabled?

    AssignmentsMailer.new_assignment(roster, effective_start_datetime, effective_end_datetime, user, Current.user)
                     .deliver_later
  end

  def notify_user_of_change
    return if previously_new_record?
    return if user_id_previously_changed?
    return unless start_date_previously_changed? || end_date_previously_changed?
    return if user == Current.user
    return unless user.change_notifications_enabled?

    AssignmentsMailer.changed_assignment(roster, effective_start_datetime, effective_end_datetime, user, Current.user)
                     .deliver_later
  end

  def notify_user_of_removal
    return unless previously_persisted? || user_id_previously_changed?

    previous_user = previously_persisted? ? user : User.find_by(id: user_id_previously_was)
    return if previous_user.blank?
    return if previous_user == Current.user
    return unless previous_user.change_notifications_enabled?

    AssignmentsMailer.deleted_assignment(roster,
                                         effective_start_datetime, effective_end_datetime,
                                         previous_user, Current.user)
                     .deliver_later
  end

  def user_in_roster
    return if roster.users.include? user

    errors.add :base, 'User is not in this roster'
  end
end

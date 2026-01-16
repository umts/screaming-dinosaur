# frozen_string_literal: true

class Assignment < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :roster

  after_destroy_commit do
    notify_user :deleted_assignment
  end
  after_update_commit :notify_appropriate_users
  after_create_commit do
    notify_user :new_assignment
  end

  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
  validate :overlaps_none
  validate :user_in_roster

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
        AssignmentsMailer.upcoming_reminder(assignment).deliver_now
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

  def notify_user(mailer_method, receiver = user)
    return unless receiver != Current.user && receiver.change_notifications_enabled?

    mail = AssignmentsMailer.send mailer_method, self, receiver, Current.user
    mail.deliver_now
  end

  # If the user's being changed, we effectively inform of the change
  # by telling the previous owner they're not responsible anymore,
  # and telling the new owner that they're newly responsible now.
  def notify_appropriate_users
    if user_id == user_id_before_last_save
      notify_user :changed_assignment
    else
      notify_user :new_assignment
      notify_user :deleted_assignment, User.find(user_id_before_last_save)
    end
  end

  def user_in_roster
    return if roster.users.include? user

    errors.add :base, 'User is not in this roster'
  end
end

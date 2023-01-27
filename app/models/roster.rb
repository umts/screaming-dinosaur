# frozen_string_literal: true

class Roster < ApplicationRecord
  has_paper_trail
  has_many :assignments, dependent: :destroy

  has_many :memberships, dependent: :destroy
  has_many :admin_memberships, -> { where(admin: true) },
           class_name: 'Membership', inverse_of: :roster
  has_many :non_admin_memberships, -> { where.not(admin: true) },
           class_name: 'Membership', inverse_of: :roster

  has_many :users, through: :memberships
  has_many :admins, through: :admin_memberships, source: :user
  has_many :non_admins, through: :non_admin_memberships, source: :user

  belongs_to :fallback_user, class_name: 'User',
                             optional: true,
                             inverse_of: 'fallback_rosters'

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def fallback_call_twiml
    return if fallback_user.blank?

    <<~TWIML
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Say>There was an application error. You are being connected to
        the backup on call contact.</Say>
        <Dial>#{fallback_user.phone}</Dial>
      </Response>
    TWIML
  end

  def fallback_text_twiml
    return if fallback_user.blank?

    <<~TWIML
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Message to="{{From}}">There was an application error. Your
        message was forwarded to the backup on call contact.</Message>
        <Message to="#{fallback_user.phone}">{{Body}}</Message>
      </Response>
    TWIML
  end

  def generate_assignments(user_ids, start_date, end_date, start_user_id)
    assignments = []
    user_ids.rotate! user_ids.index(start_user_id)
    (start_date..end_date).each_slice(7).with_index do |week, i|
      assignments << Assignment.create!(
        roster: self,
        start_date: week.first,
        end_date: week.last,
        user_id: user_ids[i % user_ids.size]
      )
    end
    assignments
  end

  def on_call_user
    assignments.current.try(:user) || fallback_user
  end

  def user_options
    as = admins.order(:last_name).map { |a| [a.full_name, a.id] }
    nas = non_admins.order(:last_name).map { |na| [na.full_name, na.id] }
    { 'Admins' => as, 'Non-Admins' => nas }
  end

  def check_for_open_dates_between(start_date, end_date)
    open_dates = []
    start_date.to_date.upto(end_date.to_date).each do |date|
      open_dates << date if Assignment.where(roster: self).between(date, date).empty?
    end
    open_dates
  end
end

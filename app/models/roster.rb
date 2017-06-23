# frozen_string_literal: true

class Roster < ApplicationRecord
  has_paper_trail
  has_many :assignments, dependent: :destroy
  has_many :memberships
  has_many :users, through: :memberships
  belongs_to :fallback_user, class_name: 'User',
                             foreign_key: :fallback_user_id, optional: true

  validates :name, presence: true, uniqueness: true

  def fallback_call_twiml
    <<~END
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Say>There was an application error. You are being connected to
        the backup on call contact.</Say>
        <Dial>#{fallback_user.phone}</Dial>
      </Response>
    END
  end

  def fallback_text_twiml
    <<~END
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Message to="{{From}}">There was an application error. Your
        message was forwarded to the backup on call contact.</Message>
        <Message to="#{fallback_user.phone}">{{Body}}</Message>
      </Response>
    END
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
end

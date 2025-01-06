# frozen_string_literal: true

class Assignment < ApplicationRecord
  class RotationGenerator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :roster_id, :integer
    attribute :user_ids
    attribute :start_user_id, :integer
    attribute :start_date, :date
    attribute :end_date, :date

    validates :roster, presence: true
    validates :user_ids, presence: true
    validates :start_user_id, presence: true, inclusion: { in: :user_ids }
    validates :start_date, presence: true
    validates :end_date, presence, comparison: { greater_than_or_equal_to: :start_date }

    def roster
      @roster ||= Roster.find_by(id: roster_id)
    end

    def generate
      generate!
      true
    rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
      false
    end

    def generate!
      validate!
      ActiveRecord::Base.transaction do
        send_notifications @roster.generate_assignments(user_ids, start_date,
                                                        end_date, start_user_id)
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.merge! e.record.errors
      raise e
    end

    def send_notifications(assignments)
      assignments.each do |assignment|
        assignment.notify :owner, of: :new_assignment, by: Current.user
      end
    end
  end
end

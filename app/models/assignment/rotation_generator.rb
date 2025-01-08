# frozen_string_literal: true

class Assignment < ApplicationRecord
  class RotationGenerator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :roster_id, :integer
    attribute :user_ids
    attribute :starting_user_id, :integer
    attribute :start_date, :date
    attribute :end_date, :date

    validates :roster, presence: true
    validates :user_ids, presence: true
    validates :starting_user_id, presence: true
    validates :start_date, presence: true
    validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }

    validate :includes_start_user

    def generate
      generate!
      true
    rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
      false
    end

    private

    def user_ids=(value)
      super(value&.map(&:to_i))
    end

    def roster
      @roster ||= Roster.find_by(id: roster_id)
    end

    def includes_start_user
      return if user_ids.blank? || starting_user_id.blank?
      return if user_ids.include? starting_user_id

      errors.add :starting_user_id, 'is not included in the list'
    end

    def generate!
      validate!
      user_ids.rotate! user_ids.index(starting_user_id)
      ActiveRecord::Base.transaction do
        (start_date..end_date).each_slice(7).with_index do |week, i|
          send_notification Assignment.create!(
            roster: @roster,
            start_date: week.first,
            end_date: week.last,
            user_id: user_ids[i % user_ids.size]
          )
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.merge! e.record.errors
      raise e
    end

    def send_notification(assignment)
      assignment.notify :owner, of: :new_assignment, by: Current.user
    end
  end
end

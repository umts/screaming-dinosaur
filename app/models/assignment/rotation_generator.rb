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
    validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date,
                                                       if: -> { start_date.present? && end_date.present? },
                                                       message: :end_date_must_be_after_start }

    validate :includes_start_user

    def generate
      generate!
      true
    rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
      false
    end

    def user_ids=(value)
      super(value&.map(&:to_i))
    end

    def roster
      return @roster if defined?(@roster)

      @roster = Roster.find_by(id: roster_id)
    end

    private

    def includes_start_user
      return if user_ids.blank? || starting_user_id.blank?
      return if user_ids.include? starting_user_id

      errors.add :starting_user_id, message: :starting_user_must_be_included
    end

    def generate!
      validate!
      [].tap do |assignments|
        ActiveRecord::Base.transaction { create_assignments_and_save!(assignments) }
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.merge! e.record.errors
      raise e
    end

    def create_assignments_and_save!(output)
      rotation = user_ids.rotate user_ids.index(starting_user_id)
      (start_date..end_date).each_slice(7).with_index do |week, i|
        output << Assignment.create!(
          roster: @roster,
          start_date: week.first,
          end_date: week.last,
          user_id: rotation[i % rotation.size]
        )
      end
    end
  end
end

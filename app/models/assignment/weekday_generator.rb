# frozen_string_literal: true

class Assignment < ApplicationRecord
  class WeekdayGenerator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :roster_id, :integer
    attribute :user_id, :integer
    attribute :start_date, :date
    attribute :end_date, :date
    attribute :start_weekday, :integer
    attribute :end_weekday, :integer

    validates :roster, presence: true
    validates :user, presence: true
    validates :start_date, presence: true
    validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
    validates :start_weekday, numericality: { in: 0...7, message: :must_be_weekday }
    validates :end_weekday, numericality: { in: 0...7, message: :must_be_weekday }

    def generate
      generate!
      true
    rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
      false
    end

    private

    def roster
      return @roster if defined?(@roster)

      @roster = Roster.find_by(id: roster_id)
    end

    def user
      return @user if defined?(@user)

      @user = User.find_by(id: user_id)
    end

    def generate!
      validate!
      ActiveRecord::Base.transaction do
        date_ranges.each do |range|
          roster.assignments.create! user:, start_date: range.begin, end_date: range.end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.merge! e.record.errors
      raise e
    end

    def date_ranges
      Enumerator.new do |enum|
        weeks.each do |sunday|
          end_weekday_adjusted = end_weekday < start_weekday ? end_weekday + 7 : end_weekday
          range_start = [start_date, sunday + start_weekday].max
          range_end = [end_date, sunday + end_weekday_adjusted].min
          next unless range_start <= range_end

          enum.yield range_start..range_end
        end
      end
    end

    def weeks
      (start_date.beginning_of_week(:sunday)..end_date.beginning_of_week(:sunday)).step(7)
    end
  end
end

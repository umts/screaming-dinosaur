# frozen_string_literal: true

class Assignment < ApplicationRecord
  class RotationGenerator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :roster_id, :integer
    attribute :user_id, :integer
    attribute :start_date, :date
    attribute :end_date, :date

    validates :roster, presence: true
    validates :user, presence: true
    validates :start_date, presence: true
    validates :end_date, presence, comparison: { greater_than_or_equal_to: :start_date }
  end
end

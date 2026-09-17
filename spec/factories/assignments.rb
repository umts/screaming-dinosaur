# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    roster
    sequence(:end_datetime) { |n| Date.current + n.days }
  end
end

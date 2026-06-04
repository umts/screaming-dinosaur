# frozen_string_literal: true

FactoryBot.define do
  factory :roster do
    sequence(:name) { |n| "Name #{n}" }
    sequence(:phone) { |n| format('+1413545%04d', n) }
    created_at { 1.week.ago }
  end
end

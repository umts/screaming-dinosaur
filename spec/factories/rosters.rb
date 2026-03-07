# frozen_string_literal: true

FactoryBot.define do
  factory :roster do
    sequence(:name) { |n| "Name #{n}" }
    sequence(:phone) { |n| format('+1413545%04d', n) }
    switchover { (16 * 60) + 30 }
  end
end

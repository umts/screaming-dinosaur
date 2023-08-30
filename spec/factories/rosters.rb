# frozen_string_literal: true

FactoryBot.define do
  factory :roster do
    sequence(:name) { |n| "Name #{n}" }
    switchover { (16 * 60) + 30 }
  end
end

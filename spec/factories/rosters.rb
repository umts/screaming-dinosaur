# frozen_string_literal: true

FactoryBot.define do
  factory :roster do
    sequence(:name) { |n| "Name #{n}" }
  end
end

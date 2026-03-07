# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:entra_uid)
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:email) { |n| "user#{n}@umass.edu" }
    sequence(:phone) { |n| format('+1413545%04d', n) }
  end
end

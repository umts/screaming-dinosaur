# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    roster
    user
    admin { false }
  end
end

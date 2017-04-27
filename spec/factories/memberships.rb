# frozen_string_literal: true

FactoryGirl.define do
  factory :membership do
    roster
    user
  end
end

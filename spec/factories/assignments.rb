# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    roster
    user { create :user, rosters: [roster] }
    start_date { Date.yesterday }
    end_date { Date.tomorrow }
  end
end

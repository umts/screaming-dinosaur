FactoryGirl.define do
  factory :assignment do
    roster
    user { FactoryGirl.create(:user, rosters: [roster]) }
    start_date Date.yesterday
    end_date Date.tomorrow
  end
end

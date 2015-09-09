FactoryGirl.define do
  factory :assignment do
    user
    start_date Date.yesterday
    end_date Date.tomorrow
  end
end

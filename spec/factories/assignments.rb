FactoryGirl.define do
  factory :assignment do
    rotation
    user { FactoryGirl.create(:user, rotations: [rotation]) }
    start_date Date.yesterday
    end_date Date.tomorrow
  end
end

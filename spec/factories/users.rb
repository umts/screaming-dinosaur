FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:spire) { |n| n.to_s.rjust(8, '0') + '@umass.edu' }
    sequence(:email) { |n| "user#{n}@umass.edu" }
    sequence(:phone) { |n| '+1' + n.to_s.rjust(10, '0') }
    rosters { [create(:roster)] }
  end
end

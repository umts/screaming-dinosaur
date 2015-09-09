FactoryGirl.define do
  factory :user do
    first_name 'First name'
    last_name 'Last name'
    sequence(:spire) { |n| n.to_s.rjust(8, '0') + '@umass.edu' }
    sequence(:email) { |n| "user#{n}@umass.edu" }
    sequence :phone
  end
end

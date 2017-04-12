FactoryGirl.define do
  factory :user do
    first_name 'First name'
    last_name 'Last name'
    sequence(:spire) { |n| n.to_s.rjust(8, '0') + '@umass.edu' }
    sequence(:email) { |n| "user#{n}@umass.edu" }
    sequence(:phone) { |n| '+1' + n.to_s.rjust(10, '0') }
    rotations { [FactoryGirl.create(:rotation)] }
  end
end

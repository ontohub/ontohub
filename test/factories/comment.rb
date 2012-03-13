
FactoryGirl.define do
  factory :comment do
    association :user
    text { Faker::Lorem.paragraph }
  end
end

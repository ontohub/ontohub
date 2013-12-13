FactoryGirl.define do
  factory :repository do
    sequence(:name) { |n| "Repository #{n}" }
    description { Faker::Lorem.paragraph }
  end
end

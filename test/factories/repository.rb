FactoryGirl.define do
  factory :repository do
    sequence(:title) { |n| "Repository #{n}" }
    description { Faker::Lorem.paragraph }
  end
end

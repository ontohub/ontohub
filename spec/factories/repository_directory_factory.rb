FactoryGirl.define do
  factory :repository_directory do
    sequence(:name) { |n| "Directory #{n}" }
    association :repository
    association :user
  end
end

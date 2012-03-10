FactoryGirl.define do
  factory :team do
    name  { Faker::Lorem.words(2).join(" ") }
  end

  factory :team_user do
    association :team
    association :user
  end
end

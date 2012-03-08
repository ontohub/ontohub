FactoryGirl.define do
  factory :team do
    name  { Faker::Name.first_name }
  end

  factory :team_user do
    association :team
    association :user
  end
end

FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    name  { Faker::Name.name }
    email { FactoryGirl.generate :email }
    password { SecureRandom.hex(10) }
  end

  factory :admin, :parent => :user do
    admin true
  end
end

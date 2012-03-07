Factory.sequence :email do |n|
  "user#{n}@example.com"
end

FactoryGirl.define do
  factory :user do
    name  { Faker::Name.name }
    email { Factory.next :email }
    password { SecureRandom.hex(10) }
  end

  factory :admin, :parent => :user do
    admin true
  end
end
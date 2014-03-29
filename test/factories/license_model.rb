FactoryGirl.define do

  factory :license_model do
    name        { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }
    url         { FactoryGirl.generate :url }
  end

end

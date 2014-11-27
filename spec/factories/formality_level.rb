FactoryGirl.define do

  factory :formality_level do
    name        { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }
  end

end

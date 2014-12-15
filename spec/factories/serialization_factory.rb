FactoryGirl.define do

  factory :serialization do
    name { Faker::Lorem.word }
    mimetype { Faker::Lorem.word}

  end

end

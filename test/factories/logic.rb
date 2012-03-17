FactoryGirl.define do
  factory :logic do
    name { Faker::Lorem.words(1)[0][0..4].upcase }
    uri { Factory.next :uri }
  end
end

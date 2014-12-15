FactoryGirl.define do

  sequence :logic_name do |n|
    "#{Faker::Lorem.words(1)[0][0..4].upcase}#{n}"
  end

  factory :logic do
    association :user
    name { FactoryGirl.generate :logic_name }
    iri { FactoryGirl.generate :iri }
  end
end

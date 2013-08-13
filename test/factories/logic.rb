FactoryGirl.define do
  
  sequence :name do |n|
    "#{Faker::Lorem.words(1)[0][0..4].upcase}#{n}"
  end
  
  factory :logic do
    name { FactoryGirl.generate :name }
    iri { FactoryGirl.generate :iri }
    association :user
  end
end

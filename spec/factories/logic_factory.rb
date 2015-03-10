FactoryGirl.define do

  sequence :logic_name do |n|
    "#{Faker::Lorem.words(1)[0][0..4].upcase}#{n}"
  end

  sequence :logic_description do
    Faker::Lorem.paragraphs.to_s
  end

  factory :logic do
    association :user
    name { FactoryGirl.generate :logic_name }
    iri { FactoryGirl.generate :iri }
    description { FactoryGirl.generate :logic_description }
    standardization_status { "Unofficial" }
  end
end

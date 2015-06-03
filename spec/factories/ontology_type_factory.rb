FactoryGirl.define do
  sequence :ontology_type_name do |n|
    "#{Faker::Lorem.word}_#{n}"
  end

  sequence :description do |n|
    "#{Faker::Lorem.sentence}_#{n}"
  end

  sequence :documentation do |n|
    "#{Faker::Internet.url}_#{n}"
  end

  factory :ontology_type do 
    name { FactoryGirl.generate :ontology_type_name }
    description { FactoryGirl.generate :description }
    documentation { FactoryGirl.generate :documentation }
  end
end

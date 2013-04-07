FactoryGirl.define do
  sequence :entity_text do |n|
    "http://host/ontology/#{n}"
  end
  
  sequence :entity_kind do |n|
    "Kind#{n}"
  end
  
  factory :entity do
    association :ontology
    text { FactoryGirl.generate :entity_text }
    kind { FactoryGirl.generate :entity_kind }
    name { Faker::Name.name }
  end
end

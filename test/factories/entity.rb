Factory.sequence :entity_text do |n|
  "scheme://host/ontology/#{n}"
end

Factory.sequence :entity_kind do |n|
  "Kind#{n}"
end

FactoryGirl.define do
  factory :entity do
    association :ontology
    text { Factory.next :entity_text }
    kind { Factory.next :entity_kind }
    name { Faker::Name.name }
  end
end

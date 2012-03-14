
Factory.sequence :axiom_name do |n|
  "Ax#{n}"
end

FactoryGirl.define do
  factory :axiom do
    association :ontology
    name { Factory.next :axiom_name }
    text { Faker::Lorem.sentence }
  end
end

FactoryGirl.define do
  factory :axiom do
    association :ontology, factory: :single_ontology
    name { FactoryGirl.generate :sentence_name }
    text { Faker::Lorem.sentence }
  end
end

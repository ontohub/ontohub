FactoryGirl.define do
  sequence :theorem_name do |n|
    "Thm#{n}"
  end

  factory :theorem do
    association :ontology, factory: :single_ontology
    association :proof_status
    name { generate :theorem_name }
    text { Faker::Lorem.sentence }
  end
end

FactoryGirl.define do
  sequence :theorem_name do |n|
    "Thm#{n}"
  end

  factory :theorem do
    association :ontology, factory: :single_ontology
    name { generate :theorem_name }
    text { Faker::Lorem.sentence }
    proof_status { 'OPN' }
  end
end

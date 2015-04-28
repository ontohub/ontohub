FactoryGirl.define do
  factory :proof_attempt_configuration do
    timeout { rand(5)+5 }

    association :prover, :with_sequenced_name
    association :logic_mapping
    association :ontology
  end
end

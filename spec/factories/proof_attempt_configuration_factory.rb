FactoryGirl.define do
  factory :proof_attempt_configuration do |pac|
    timeout { rand(5)+5 }

    association :prover, :with_sequenced_name
    association :logic_mapping
    association :ontology

    pac.after(:build) do |pac|
      unless pac.axiom_selection
        pac.axiom_selection = FactoryGirl.create :axiom_selection,
                                                 proof_attempt_configuration: pac
      end
    end
  end
end

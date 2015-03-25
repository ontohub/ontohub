FactoryGirl.define do
  factory :proof_attempt do
    tactic_script { 'SPASS Tactic Script' }
    time_taken { rand(5) }

    association :proof_status, factory: :proof_status_open
    association :theorem
    association :prover

    association :proof_attempt_configuration

    after(:build) do |proof_attempt|
      proof_attempt.proof_attempt_configuration.ontology =
        proof_attempt.ontology
      build :prover_output, proof_attempt: proof_attempt
    end

    after(:create) do |proof_attempt|
      proof_attempt.prover_output.save!
    end
  end
end

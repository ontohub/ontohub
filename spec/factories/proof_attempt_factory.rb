FactoryGirl.define do
  factory :proof_attempt do
    time_taken { rand(5) }

    association :proof_status, factory: :proof_status_open
    association :theorem
    association :prover, :with_sequenced_name

    after(:build) do |proof_attempt|
      if proof_attempt.proof_attempt_configuration
        proof_attempt.proof_attempt_configuration.proof_attempt = proof_attempt
      else
        proof_attempt.proof_attempt_configuration =
          build :proof_attempt_configuration,
                proof_attempt: proof_attempt
      end
    end

    trait :with_tactic_script do
      after(:build) do |proof_attempt|
        proof_attempt.tactic_script =
          build :tactic_script, proof_attempt: proof_attempt
      end
      after(:create) do |proof_attempt|
        proof_attempt.tactic_script.save!
      end
    end

    trait :proven do
      association :proof_status, factory: :proof_status_proven
      after(:build) do |proof_attempt|
        create :prover_output, proof_attempt: proof_attempt
      end
      after(:create) do |proof_attempt|
        proof_attempt.prover_output.save!
      end
    end
  end
end

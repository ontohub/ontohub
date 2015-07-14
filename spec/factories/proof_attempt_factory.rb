FactoryGirl.define do
  factory :proof_attempt do
    time_taken { rand(5) }

    association :proof_status, factory: :proof_status_open
    association :theorem
    association :prover, :with_sequenced_name
    association :proof_attempt_configuration

    after(:build) do |proof_attempt|
      proof_attempt.proof_attempt_configuration.save!
      proof_attempt.tactic_script =
        build :tactic_script, proof_attempt: proof_attempt
      create :prover_output, proof_attempt: proof_attempt
    end

    after(:create) do |proof_attempt|
      proof_attempt.prover_output.save!
      proof_attempt.tactic_script.save!
    end
  end
end

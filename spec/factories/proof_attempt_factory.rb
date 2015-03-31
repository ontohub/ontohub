FactoryGirl.define do
  factory :proof_attempt do
    prover_output { 'SPASS Output' }
    tactic_script { 'SPASS Tactic Script' }
    time_taken { rand(5) }

    association :proof_status, factory: :proof_status_open
    association :theorem
    association :prover
    association :proof_attempt_configuration
  end
end

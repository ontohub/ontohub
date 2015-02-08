FactoryGirl.define do
  factory :proof_attempt do
    prover { 'SPASS' }
    prover_output { 'SPASS Output' }
    tactic_script { 'SPASS Tactic Script' }
    time_taken { rand(5) }

    association :proof_status, factory: :proof_status_proven
    association :theorem
  end
end

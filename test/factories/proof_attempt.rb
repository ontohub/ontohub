FactoryGirl.define do
  factory :proof_attempt do
    status { 'OPN' }
    prover { 'spass' }
    prover_output { 'SPASS Output' }
    tactic_script { 'SPASS Tactic Script' }
    time_taken { rand(10) + 1 }

    association :theorem
  end
end

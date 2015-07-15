FactoryGirl.define do
  factory :axiom_selection do
    after(:build) do |axiom_selection|
      unless axiom_selection.proof_attempt_configuration
        proof_attempt = build :proof_attempt
        axiom_selection.proof_attempt_configuration =
          proof_attempt.proof_attempt_configuration
      end
    end
  end

  factory :manual_axiom_selection do
    after(:build) do |mas|
      unless mas.proof_attempt_configuration
        proof_attempt = build :proof_attempt
        mas.axiom_selection.proof_attempt_configuration =
          proof_attempt.proof_attempt_configuration
      end
    end
  end

  factory :sine_axiom_selection do
    commonness_threshold { 0 }
    depth_limit { -1 }
    tolerance { 1.0 }
    after(:build) do |sas|
      unless sas.proof_attempt_configuration
        proof_attempt = build :proof_attempt
        sas.axiom_selection.proof_attempt_configuration =
          proof_attempt.proof_attempt_configuration
      end
    end
  end
end

FactoryGirl.define do
  factory :axiom_selection do
    association :proof_attempt_configuration
  end

  factory :manual_axiom_selection do
  end

  factory :sine_axiom_selection do
    commonness_threshold { 0 }
    depth_limit { -1 }
    tolerance { 1.0 }
  end
end

FactoryGirl.define do
  factory :axiom_selection do
    association :proof_attempt_configuration
  end

  factory :manual_axiom_selection do
  end
end

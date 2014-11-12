FactoryGirl.define do
  factory :proof_status do
    initialize_with { ProofStatus.find('OPN') }
  end
end

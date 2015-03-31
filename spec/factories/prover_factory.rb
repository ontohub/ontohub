FactoryGirl.define do
  sequence :prover_name do |n|
    "prover-#{n}"
  end

  factory :prover do
    name { 'SPASS' }

    trait :with_sequenced_name do
      after(:build) do |prover|
        prover.name = generate :prover_name
      end
    end
  end
end

FactoryGirl.define do
  sequence :prover_name do |n|
    "prover-#{n}"
  end

  factory :prover do
    name { 'SPASS' }
    display_name { 'SPASS Prover' }

    initialize_with do
      Prover.find_by_name(name) || Prover.new(name: name)
    end

    trait :with_sequenced_name do
      after(:build) do |prover|
        prover.name = generate :prover_name
        prover.display_name = prover.name.sub('-', ' ')
      end
    end
  end
end

FactoryGirl.define do
  factory :axiom_selection do
  end

  factory :manual_axiom_selection do
  end

  factory :sine_axiom_selection do
    commonness_threshold { 0 }
    depth_limit { -1 }
    tolerance { 1.0 }

    # Allow to pass arguments that are not model attributes.
    transient do
      ontology_fixture_file nil
    end

    trait :with_auxiliary_objects do
      after(:create) do |sas, evaluator|
        if evaluator.ontology_fixture_file.nil?
          raise 'ontology_fixture_file must be set for :with_auxiliary_objects trait'
        end
        repository = create :repository
        ontology_fixture_file = evaluator.ontology_fixture_file

        parent_ontology_version =
          version_for_file(repository,
                           ontology_file(*ontology_fixture_file))
        parent_ontology_version.parse
        parent_ontology = parent_ontology_version.ontology

        ontology = parent_ontology.children.
          where(name: 'SubclassToleranceOnePointFive').first
        theorem = ontology.theorems.first

        proof_attempt = create :proof_attempt, theorem: theorem
        proof_attempt_configuration = proof_attempt.proof_attempt_configuration
        proof_attempt_configuration.axiom_selection = sas.axiom_selection
        sas.axiom_selection.proof_attempt_configurations = [proof_attempt_configuration]
      end
    end
  end

  factory :sine_fresym_axiom_selection do
    commonness_threshold { 0 }
    depth_limit { -1 }
    tolerance { 1.0 }
    minimum_support { 1 }
    minimum_support_type { 'absolute' }
    symbol_set_tolerance { 1.0 }
  end

  factory :frequent_symbol_set_mining_axiom_selection do
    depth_limit { -1 }
    minimal_symbol_set_size { 2 }
    minimum_support { 1 }
    minimum_support_type { 'absolute' }
    short_axiom_tolerance { 0 }
  end
end

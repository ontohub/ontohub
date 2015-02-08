FactoryGirl.define do
  factory :proof_status_success, class: ProofStatus do
    initialize_with { ProofStatus.find('SUC') }
  end

  factory :proof_status_open, class: ProofStatus do
    initialize_with { ProofStatus.find(ProofStatus::DEFAULT_OPEN_STATUS) }
  end

  factory :proof_status_proven, class: ProofStatus do
    initialize_with { ProofStatus.find(ProofStatus::DEFAULT_PROVEN_STATUS) }
  end

  factory :proof_status_disproven, class: ProofStatus do
    initialize_with { ProofStatus.find(ProofStatus::DEFAULT_DISPROVEN_STATUS) }
  end

  factory :proof_status_unknown, class: ProofStatus do
    initialize_with { ProofStatus.find(ProofStatus::DEFAULT_UNKNOWN_STATUS) }
  end

  factory :proof_statuses, class: Array do
    skip_create

    statuses = [
      { 'identifier' => ProofStatus::DEFAULT_OPEN_STATUS,
        'name' => 'Open',
        'label' => 'primary',
        'description' => 'A success value has never been established.',
        'solved' => false},
      { 'identifier' => 'SUC',
        'name' => 'Success',
        'label' => 'primary',
        'description' => 'The logical data has been processed successfully.',
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_PROVEN_STATUS,
        'name' => 'Theorem',
        'label' => 'success',
        'description' =>
          ['All models of Ax are models of C.',
          '- F is valid, and C is a theorem of Ax.',
          '- Possible dataforms are Proofs of C from Ax.'].join("\n"),
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_DISPROVEN_STATUS,
        'name' => 'NoConsequence',
        'label' => 'danger',
        'description' =>
          ['Some interpretations are models of Ax,',
          'some models of Ax are models of C, and',
          'some models of Ax are models of ~C.',
          '- F is not valid, F is satisfiable, ~F is not valid,',
          '~F is satisfiable, and C is not a theorem of Ax.',
          '- Possible dataforms are pairs of models,',
          'one Model of Ax | C and one Model of Ax | ~C.'].join("\n"),
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_UNKNOWN_STATUS,
        'name' => 'Unknown',
        'label' => 'primary',
        'description' =>
          'Success value unknown, and no assumption has been made.',
        'solved' => false}]

    initialize_with { statuses.map { |s| ProofStatus.create(s) } }
  end
end

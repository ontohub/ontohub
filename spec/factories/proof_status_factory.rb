FactoryGirl.define do
  factory :proof_status_success, class: ProofStatus do
    initialize_with { ProofStatus.find('SUC') }
  end

  factory :proof_status_csa, class: ProofStatus do
    initialize_with { ProofStatus.find('CSA') }
  end

  factory :proof_status_csas, class: ProofStatus do
    initialize_with { ProofStatus.find('CSAS') }
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

  factory :proof_status_contr, class: ProofStatus do
    initialize_with { ProofStatus.find(ProofStatus::CONTRADICTORY) }
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
        'solved' => false},
      { 'identifier' => ProofStatus::CONTRADICTORY,
        'name' => 'Contradictory',
        'label' => 'primary',
        'description' =>
          ['Contradictory ProofStatuses',
           'At least one ProofAttempt resulted in "proven" result',
           'while at least another ProofAttempt resulted in "disproven".',
           'This indicates an error in the system.'].join("\n"),
        'solved' => true},
      { 'identifier' => 'CSA',
        'name' => 'CounterSatisfiable',
        'label' => 'danger',
        'description' =>
          ['Some interpretations are models of Ax, and',
           'some models of Ax are models of ~C.',
           '- F is not valid, ~F is satisfiable, and C is not a theorem of Ax.',
           '- Possible dataforms are Models of Ax | ~C.'].join("\n"),
        'solved' => true},
      { 'identifier' => 'CSAS',
        'name' => 'CounterSatisfiableWithSubset',
        'label' => 'danger',
        'description' =>
          ['Countersatifiability shown with a subset of the axioms - Countersatisfiability of the goal has not been proven yet.',
           'Let SAx be the selected subset of Ax, SF = SAx + {C}.',
           'Some interpretations are models of the selected subset of SAx, and',
           'some models of SAx are models of ~C.',
           '- SF is not valid, ~SF is satisfiable, and C is not a theorem of SAx.',
           '- Possible dataforms are Models of SAx | ~C'].join("\n"),
        'solved' => true}]

    initialize_with do
      statuses.map do |status|
        ProofStatus.where(identifier: status['identifier']).any? ||
          ProofStatus.create(status)
      end
    end
  end
end

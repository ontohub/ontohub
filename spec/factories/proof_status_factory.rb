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
        'description' => 'Open description',
        'solved' => false},
      { 'identifier' => 'SUC',
        'name' => 'Success',
        'label' => 'primary',
        'description' => 'Success description',
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_PROVEN_STATUS,
        'name' => 'Theorem',
        'label' => 'success',
        'description' => 'Theorem description',
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_DISPROVEN_STATUS,
        'name' => 'NoConsequence',
        'label' => 'danger',
        'description' => 'NoConsequence description',
        'solved' => true},
      { 'identifier' => ProofStatus::DEFAULT_UNKNOWN_STATUS,
        'name' => 'Unknown',
        'label' => 'primary',
        'description' => 'Unknown description',
        'solved' => false},
      { 'identifier' => ProofStatus::CONTRADICTORY,
        'name' => 'Contradictory',
        'label' => 'primary',
        'description' => 'Contradictory description',
        'solved' => true},
      { 'identifier' => 'CSA',
        'name' => 'CounterSatisfiable',
        'label' => 'danger',
        'description' => 'CounterSatisfiable description',
        'solved' => true},
      { 'identifier' => 'CSAS',
        'name' => 'CounterSatisfiableWithSubset',
        'label' => 'danger',
        'description' => 'CounterSatisfiableWithSubset description',
        'solved' => true}]

    initialize_with do
      statuses.map do |status|
        if ProofStatus.where(identifier: status['identifier']).any?
          pr_status = ProofStatus.where(identifier: status['identifier']).first
        else
          pr_status = ProofStatus.create(status)
        end
        LocId.where(locid: "/proof-statuses/#{pr_status.identifier}",
                    assorted_object_id: pr_status.id,
                    assorted_object_type: pr_status.class,
                   ).first_or_create!
      end
    end
  end
end

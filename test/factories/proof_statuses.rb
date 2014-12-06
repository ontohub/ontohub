FactoryGirl.define do
  factory :proof_statuses, class: Array do
    skip_create

    statuses = [
      { 'identifier' => 'OPN',
        'name' => 'Open',
        'label' => 'default',
        'description' => 'Not solved at all.',
        'solved' => false},
      { 'identifier' => 'USD',
        'name' => 'Unsolved',
        'label' => 'default',
        'description' => 'Not solved by a system.',
        'solved' => false},
      { 'identifier' => 'UNK',
        'name' => 'Unknown',
        'label' => 'default',
        'description' => ['Not solved by a system,',
          ' and no assumption made about the status.'].join("\n"),
        'solved' => false},
      { 'identifier' => 'SOL',
        'name' => 'Solved',
        'label' => 'success',
        'description' => 'Solved by a system.',
        'solved' => true},
      { 'identifier' => 'SAT',
        'name' => 'Satisfiable',
        'label' => 'success',
        'description' => ['Some interpretations are models of Ax',
          'Some models of Ax are models of C',
          '+ Shows: F is satisfiable; ~F is not valid; C is not a theorem of Ax',
          '+ Output: Model or saturation of Ax and C.'].join("\n"),
        'solved' => true}]

    initialize_with { statuses.map{ |s| ProofStatus.create(s) } }
  end
end

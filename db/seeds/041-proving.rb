repository = Repository.find_by_path('default')
%w(v__T strict_partial_order).each do |ontology_name|
  ontology = repository.ontologies.find_by_name(ontology_name)
  Proof.new({ontology_id: ontology.id,
             proof: {axiom_selection_method: 'manual_axiom_selection'}},
            prove_asynchronously: false).save!
end

ontology = repository.ontologies.find_by_name('v__T')
theorem = ontology.theorems.find_by_name('antisymmetric')
Proof.new({ontology_id: ontology.id,
           theorem_id: theorem.id,
           proof: {axiom_selection_method: 'manual_axiom_selection'}},
          prove_asynchronously: false).save!

ontology = repository.ontologies.find_by_name('SubclassToleranceOne')
theorem = ontology.theorems.find_by_name('beer < liquid')
Proof.new({ontology_id: ontology.id,
           theorem_id: theorem.id,
           proof: {axiom_selection_method: 'sine_axiom_selection',
                   sine_axiom_selection: {commonness_threshold: 1,
                                          depth_limit: -1,
                                          tolerance: 1}}},
          prove_asynchronously: false).save!

ontology = repository.ontologies.find_by_name('SubclassToleranceOnePointFive')
theorem = ontology.theorems.find_by_name('beer < liquid')
Proof.new({ontology_id: ontology.id,
           theorem_id: theorem.id,
           proof: {axiom_selection_method: 'sine_axiom_selection',
                   sine_axiom_selection: {commonness_threshold: 1,
                                          depth_limit: -1,
                                          tolerance: 1}}},
          prove_asynchronously: false).save!

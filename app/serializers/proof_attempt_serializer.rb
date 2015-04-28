class ProofAttemptSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :number

    def iri
      qualified_locid_for(object)
    end
  end

  attributes :iri,
             :number,
             :used_prover
  has_one :tactic_script
  has_one :prover_output, serializer: ProverOutputSerializer::Reference
  attributes :time_taken,
             :evaluation_state
  has_one :theorem, serializer: TheoremSerializer::Reference
  has_one :proof_attempt_configuration,
          serializer: ProofAttemptConfigurationSerializer::Reference
  has_one :proof_status, serializer: ProofStatusSerializer::Reference
  attributes :used_axioms
  attributes :used_theorems
  attributes :generated_axioms

  def iri
    Reference.new(object).iri
  end

  def evaluation_state
    object.state
  end

  def used_prover
    object.prover.try(:name)
  end

  def used_axioms
    qualified_locid_for(object, :used_axioms)
  end

  def generated_axioms
    qualified_locid_for(object, :generated_axioms)
  end

  def used_theorems
    qualified_locid_for(object, :used_theorems)
  end
end

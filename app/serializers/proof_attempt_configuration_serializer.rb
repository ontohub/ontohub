class ProofAttemptConfigurationSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri

    def iri
      url_for([object.proof_attempt, :'proof-attempt-configuration'])
    end
  end

  attributes :iri
  attributes :number

  attributes :selected_prover
  attributes :selected_timeout
  has_one :selected_logic_mapping, serializer: LogicMappingSerializer::Reference
  attributes :selected_axioms
  attributes :selected_theorems

  def iri
    Reference.new(object).iri
  end

  def number
    object.proof_attempt.number
  end

  def selected_logic_mapping
    object.logic_mapping
  end

  def selected_prover
    object.prover.try(:name)
  end

  def selected_timeout
    object.timeout
  end

  def selected_axioms
    url_for([object.proof_attempt,
             :'proof-attempt-configuration', :selected_axioms])
  end

  def selected_theorems
    url_for([object.proof_attempt,
             :'proof-attempt-configuration', :selected_theorems])
  end
end

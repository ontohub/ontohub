class ProverOutputSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri

    def iri
      url_for([object.proof_attempt, :prover_output])
    end
  end

  attributes :iri
  attributes :prover
  attributes :content
  has_one :proof_attempt, serializer: ProofAttemptSerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def prover
    object.prover.try(:name)
  end
end

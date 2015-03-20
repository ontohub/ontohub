# The Proof class is not supposed to be stored in the database. Its purpose is
# to allow for an easy way to create proving commands in the RESTful manner.
# It is called Proof to comply with the ProofsController which in turn gets
# called on */proofs routes.
# This class prepares the proving procedure and creates the models which are
# presented in the UI (ProofAttempt).
class Proof < FakeRecord
  class ProversValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      not_provers = value.reject { |id| Prover.where(id: id).any? }
      if not_provers.any?
        record.errors.add attribute, "#{not_provers} are not provers"
      end
    end
  end

  attr_reader :proof_obligation, :provers, :ontology
  attr_reader :proof_attempts

  validates :provers, provers: true

  def initialize(opts)
    opts[:proof] ||= {}
    opts[:proof][:provers] ||= []

    @ontology = Ontology.find(opts[:ontology_id])
    # HACK: remove the empty string from params
    # Rails 4.2 introduces the html form option :include_hidden
    @provers = opts[:proof][:provers].select(&:present?).map(&:to_i)
    @proof_obligation = initialize_proof_obligation(opts)

    initialize_proof_attempts
  end

  def save!
    proof_attempts.each(&:save!)
    ontology_version.update_state! :pending
    CollectiveProofAttemptWorker.perform_async(proof_obligation.class.to_s,
                                               proof_obligation.id,
                                               provers)
  end

  def theorem?
    proof_obligation.is_a?(Theorem)
  end

  def to_s
    proof_obligation.to_s
  end

  protected

  def ontology_version
    @ontology_version ||= ontology.current_version
  end

  def initialize_proof_obligation(opts)
    @proof_obligation ||=
      if opts[:theorem_id]
        Theorem.find(opts[:theorem_id])
      else
        ontology_version
      end
  end

  def initialize_proof_attempts
    @proof_attempts = []
    provers.each do |prover_id|
      proof_attempt_configuration = build_proof_attempt_configuration(prover_id)
      proof_attempts += build_proof_attempts(proof_attempt_configuration)
    end
  end

  def build_proof_attempt_configuration(prover_id)
    proof_attempt_configuration = ProofAttemptConfiguration.new
    proof_attempt_configuration.prover = Prover.where(id: prover_id).first
    proof_attempt_configuration
  end

  def build_proof_attempts(proof_attempt_configuration)
    if theorem?
      [build_proof_attempt(proof_obligation, proof_attempt_configuration)]
    else
      proof_obligation.ontology.theorems.map do |theorem|
        build_proof_attempt(theorem, proof_attempt_configuration)
      end
    end
  end

  def build_proof_attempt(theorem, proof_attempt_configuration)
    proof_attempt = ProofAttempt.new
    proof_attempt.theorem = theorem
    proof_attempt.proof_attempt_configuration = proof_attempt_configuration
    proof_attempt
  end
end

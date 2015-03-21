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

  attr_reader :proof_obligation, :prover_ids, :ontology
  attr_reader :proof_attempts, :prove_options_list, :options_to_attempts_hash

  validates :prover_ids, provers: true

  def initialize(opts)
    opts[:proof] ||= {}
    opts[:proof][:provers] ||= []

    @ontology = Ontology.find(opts[:ontology_id])
    # HACK: remove the empty string from params
    # Rails 4.2 introduces the html form option :include_hidden
    @prover_ids = opts[:proof][:provers].select(&:present?).map(&:to_i)
    @proof_obligation = initialize_proof_obligation(opts)

    initialize_provers
    initialize_prove_options_list
    initialize_proof_attempts
  end

  def save!
    proof_attempts.each(&:save!)
    options_and_pa_ids = normalize_for_async_call(options_to_attempts_hash)
    ontology_version.update_state!(:pending)
    CollectiveProofAttemptWorker.perform_async(proof_obligation.class.to_s,
                                               proof_obligation.id,
                                               options_and_pa_ids)
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

  def initialize_provers
    @provers = @prover_ids.map { |prover| Prover.where(id: prover).first }
    @provers.compact!
    @provers = [nil] if @provers.blank?
  end

  def initialize_prove_options_list
    @prove_options_list = @provers.map do |prover|
      Hets::ProveOptions.new(prover: prover)
    end
  end

  def initialize_proof_attempts
    @options_to_attempts_hash = {}
    @proof_attempts = []

    prove_options_list.each do |prove_options|
      pa_configuration = build_proof_attempt_configuration(prove_options)
      current_pas = build_proof_attempts(pa_configuration)

      @options_to_attempts_hash[prove_options] = current_pas
      @proof_attempts += current_pas
    end
  end

  def build_proof_attempt_configuration(prove_options)
    proof_attempt_configuration = ProofAttemptConfiguration.new
    proof_attempt_configuration.prover =
      Prover.find_by_name(prove_options.options[:prover])
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

  def normalize_for_async_call(options_to_attempts_hash)
    result = {}
    options_to_attempts_hash.each do |prove_options, proof_attempts|
      result[prove_options.to_json] = proof_attempts.map(&:id)
    end
    result
  end
end

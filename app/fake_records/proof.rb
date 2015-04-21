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

  TIMEOUT_RANGE = [5.seconds, 10.seconds, 30.seconds,
                   1.minutes, 5.minutes, 10.minutes, 30.minutes,
                   1.hours, 6.hours,
                   1.days, 2.days, 7.days]

  attr_reader :proof_obligation, :prover_ids, :ontology, :timeout, :axioms
  attr_reader :proof_attempts, :prove_options_list, :options_to_attempts_hash
  attr_reader :prove_asynchronously

  validates :prover_ids, provers: true
  validates :timeout,
            inclusion: {in: (TIMEOUT_RANGE.first..TIMEOUT_RANGE.last)},
            if: :timeout_present?

  def initialize(opts, prove_asynchronously: true)
    @prove_asynchronously = prove_asynchronously
    opts[:proof] ||= {}
    opts[:proof][:prover_ids] ||= []

    @ontology = Ontology.find(opts[:ontology_id])
    @timeout = opts[:proof][:timeout].to_i if opts[:proof][:timeout].present?

    initialize_proof_obligation(opts)
    initialize_provers(opts)
    initialize_axioms(opts)
    initialize_prove_options_list
    initialize_proof_attempts
  end

  def save!
    proof_attempts.each(&:save!)
    ontology_version.update_state!(:pending)
    prove(normalize_for_async_call(options_to_attempts_hash))
  end

  def theorem?
    proof_obligation.is_a?(Theorem)
  end

  def to_s
    proof_obligation.to_s
  end

  protected

  # HACK: Remove the empty string from params.
  # Rails 4.2 introduces the html form option :include_hidden for this task.
  def normalize_check_box_ids(collection)
    collection.select(&:present?).map(&:to_i) if collection
  end

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

  def initialize_provers(opts)
    @prover_ids = normalize_check_box_ids(opts[:proof][:prover_ids])
    @provers = @prover_ids.map { |prover| Prover.where(id: prover).first }
    @provers.compact!
    @provers = [nil] if @provers.blank?
  end

  def initialize_axioms(opts)
    axiom_ids = normalize_check_box_ids(opts[:proof][:axioms])
    @axioms = axiom_ids.map { |id| Axiom.find(id) } if @axiom_ids
  end

  def initialize_prove_options_list
    @prove_options_list = @provers.map do |prover|
      options = {prover: prover}
      options[:axioms] = axioms if axioms.present?
      options[:timeout] = timeout if timeout.present?
      Hets::ProveOptions.new(options)
    end
  end

  def initialize_proof_attempts
    @options_to_attempts_hash = {}
    @proof_attempts = []

    prove_options_list.each do |prove_options|
      pa_configuration = build_proof_attempt_configuration(prove_options)
      current_proof_attempts = build_proof_attempts(pa_configuration)

      @options_to_attempts_hash[prove_options] = current_proof_attempts
      @proof_attempts += current_proof_attempts
    end
  end

  def build_proof_attempt_configuration(prove_options)
    proof_attempt_configuration = ProofAttemptConfiguration.new
    proof_attempt_configuration.prover =
      Prover.find_by_name(prove_options.options[:prover])
    proof_attempt_configuration.timeout = timeout
    proof_attempt_configuration
  end

  def build_proof_attempts(proof_attempt_configuration)
    proof_attempt_configuration.ontology = proof_obligation.ontology
    if theorem?
      [build_proof_attempt(proof_obligation, proof_attempt_configuration)]
    else
      proof_obligation.theorems.map do |theorem|
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
    CollectiveProofAttemptWorker.
      normalize_for_async_call(options_to_attempts_hash)
  end

  def prove(options_and_pa_ids)
    # Sidekiq requires `perform` to be defined on an instance while we added a
    # class method `perform_async` to force the usage of a specific queue.
    if prove_asynchronously
      proving_object = CollectiveProofAttemptWorker
      proving_method = :perform_async
    else
      proving_object = CollectiveProofAttemptWorker.new
      proving_method = :perform
    end
    proving_object.send(proving_method,
                        proof_obligation.class.to_s,
                        proof_obligation.id,
                        options_and_pa_ids)
  end

  def timeout_present?
    timeout.present?
  end
end

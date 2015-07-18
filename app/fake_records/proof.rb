# The Proof class is not supposed to be stored in the database. Its purpose is
# to allow for an easy way to create proving commands in the RESTful manner.
# It is called Proof to comply with the ProofsController which in turn gets
# called on */proofs routes.
# This class prepares the proving procedure and creates the models which are
# presented in the UI (ProofAttempt).
class Proof < FakeRecord
  class AssociatedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.try(:valid?)
        record.errors.add attribute, 'is not valid'
      end
    end
  end

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

  # flags
  attr_reader :prove_asynchronously
  # ontology related
  attr_reader :ontology, :proof_obligation
  # prover related
  attr_reader :prover_ids, :provers
  # axiom related
  attr_reader :axiom_selection_method, :specific_axiom_selection, :axioms
  # timeout
  attr_reader :timeout
  # result related
  attr_reader :proof_attempts

  validates :prover_ids, provers: true
  validates :axiom_selection_method, inclusion: {in: AxiomSelection::METHODS}
  validates :timeout,
            inclusion: {in: (TIMEOUT_RANGE.first..TIMEOUT_RANGE.last)},
            if: :timeout_present?
  validates :specific_axiom_selection, associated: true

  delegate :to_s, to: :proof_obligation

  def initialize(opts, prove_asynchronously: true)
    prepare_options(opts)
    @prove_asynchronously = prove_asynchronously
    @ontology = Ontology.find(opts[:ontology_id])
    @timeout = opts[:proof][:timeout].to_i if opts[:proof][:timeout].present?
    initialize_proof_obligation(opts)
    initialize_provers(opts)
    initialize_axiom_selection(opts)
    initialize_proof_attempts(opts)
  end

  def save!
    ActiveRecord::Base.transaction do
      specific_axiom_selection.save!
      proof_attempts.each do |proof_attempt|
        proof_attempt.save!
        proof_attempt.proof_attempt_configuration.save!
      end
    end
    prove
  end

  def axiom_selection
    specific_axiom_selection.try(:axiom_selection)
  end

  def theorem?
    proof_obligation.is_a?(Theorem)
  end

  protected

  # This is needed for the validations to run.
  def prepare_options(opts)
    opts[:proof] ||= {}
    opts[:proof][:prover_ids] ||= []
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

  # HACK: Remove the empty string from params.
  # Rails 4.2 introduces the html form option :include_hidden for this task.
  def normalize_check_box_ids(collection)
    collection.select(&:present?).map(&:to_i) if collection
  end

  def initialize_axioms(opts)
    axiom_ids = normalize_check_box_ids(opts[:proof][:axioms])
    @axioms = axiom_ids.map { |id| Axiom.find(id) } if axiom_ids
  end

  def initialize_axiom_selection(opts)
    @axiom_selection_method = opts[:proof][:axiom_selection_method].try(:to_sym)
    build_axiom_selection(opts)
  end

  def initialize_proof_attempts(opts)
    @proof_attempts = []
    if theorem?
      initialize_proof_attempts_for_theorem(opts, proof_obligation)
    else
      proof_obligation.theorems.each do |theorem|
        initialize_proof_attempts_for_theorem(opts, theorem)
      end
    end
  end

  def initialize_proof_attempts_for_theorem(opts, theorem)
    provers.each do |prover|
      pac = ProofAttemptConfiguration.new
      pac.prover = prover
      pac.timeout = timeout
      pac.axiom_selection = axiom_selection

      proof_attempt = ProofAttempt.new
      proof_attempt.theorem = theorem
      proof_attempt.proof_attempt_configuration = pac
      pac.proof_attempt = proof_attempt

      @proof_attempts << proof_attempt
    end
  end

  def build_axiom_selection(opts)
    if AxiomSelection::METHODS.include?(axiom_selection_method)
      send("build_#{axiom_selection_method}", opts)
    end
  end

  def build_manual_axiom_selection(opts)
    axiom_ids = normalize_check_box_ids(opts[:proof][:axioms])
    @specific_axiom_selection = ManualAxiomSelection.new
    if axiom_ids
      specific_axiom_selection.axioms =
        axiom_ids.map { |id| Axiom.unscoped.find(id) }
    end
  end

  def build_sine_axiom_selection(opts)
    @specific_axiom_selection =
      SineAxiomSelection.new(opts[:proof][:sine_axiom_selection])
  end

  def timeout_present?
    timeout.present?
  end

  def prove
    proof_attempts.each do |proof_attempt|
      if prove_asynchronously
        ProofExecutionWorker.perform_async(proof_attempt.id)
      else
        ProofExecutionWorker.new.perform(proof_attempt.id)
      end
    end
  end
end

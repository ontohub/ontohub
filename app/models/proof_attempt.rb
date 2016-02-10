class ProofAttempt < OntohubBaseModel
  include Numbering
  include StateUpdater

  numbering_parent_column 'sentence_id'

  belongs_to :theorem, foreign_key: 'sentence_id'
  belongs_to :proof_status
  belongs_to :prover
  belongs_to :proof_attempt_configuration, dependent: :destroy
  has_one :axiom_selection, through: :proof_attempt_configuration
  has_one :prover_output
  has_one :tactic_script, dependent: :destroy
  has_many :generated_axioms, dependent: :destroy
  has_and_belongs_to_many :used_axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: 'used_axioms_proof_attempts'
  has_and_belongs_to_many :used_theorems,
                          class_name: 'Theorem',
                          association_foreign_key: 'sentence_id',
                          join_table: 'used_axioms_proof_attempts'

  attr_accessible :time_taken,
                  :number,
                  :state,
                  :state_updated_at,
                  :last_error

  validates :state, inclusion: {in: State::STATES}
  validates :theorem, presence: true

  after_create :generate_locid
  before_save :set_default_proof_status
  after_save :update_theorem_status

  scope :latest, order('number DESC')

  has_one :ontology, through: :theorem


  def set_default_proof_status
    self.proof_status ||= ProofStatus.find(ProofStatus::DEFAULT_OPEN_STATUS)
  end

  def generate_locid
    LocId.create(
      locid: "#{theorem.locid}//#{self.class.to_s.underscore.dasherize}-#{number}",
      assorted_object_id: self.id,
      assorted_object_type: self.class.name)

  end

  def update_theorem_status
    theorem.update_proof_status!
  end

  def associate_prover_with_ontology_version
    ontology_version = theorem.ontology.current_version
    unless ontology_version.provers.include?(prover)
      ontology_version.provers << prover
      ontology_version.save!
    end
  end

  def retry_failed
    ProofExecutionWorker.perform_async(id)
  end

  def proper_subset_of_axioms_selected?
    selected = proof_attempt_configuration.axiom_selection.axioms
    available = theorem.ontology.axioms
    selected.any? && selected.count < available.count
  end
end

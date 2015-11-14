class AxiomSelection < ActiveRecord::Base
  METHODS = %i(manual_axiom_selection
               sine_axiom_selection
               sine_fresym_axiom_selection)

  acts_as_superclass

  attr_accessible :finished

  has_many :proof_attempt_configurations
  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: "axioms_axiom_selections"

  # Frequent symbol sets for frequent symbol set mining axiom selections:
  has_many :frequent_symbol_sets, dependent: :destroy

  def initialize(*args)
    super(*args)
    self.finished = false
  end

  def call
    # overwrite this in the "subclasses"
  end

  def ontology
    @ontology ||= goal.ontology
  end

  def goal
    @goal ||= proof_attempt_configurations.first.proof_attempt.theorem
  end

  def record_processing_time
    start = Time.now
    yield
    finish = Time.now
    self.processing_time = (finish - start) * 1000
    save!
  end

  # This key is used for mutex locking: The selection only has to be done once,
  # but many jobs may call it in parallel.
  def lock_key
    "#{self.class.to_s.underscore.dasherize}-#{id}"
  end

  protected

  def mark_as_finished!
    self.finished = true
    save!
  end
end
